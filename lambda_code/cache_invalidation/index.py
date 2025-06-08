import json
import os
import re
import time
from typing import List, Set, Dict, Any
import boto3
from botocore.exceptions import ClientError

# Initialize clients
cloudfront = boto3.client('cloudfront')
sqs = boto3.client('sqs')

# Environment variables
DISTRIBUTION_ID = os.environ['CLOUDFRONT_DISTRIBUTION_ID']
INVALIDATION_MODE = os.environ.get('INVALIDATION_MODE', 'direct')
PATH_MAPPINGS = json.loads(os.environ.get('PATH_MAPPINGS', '[]'))
MAX_RETRIES = 3


def handler(event: Dict[str, Any], _context: Any) -> Dict[str, Any]:
    """
    Process S3 events from SQS queue and create CloudFront invalidations.
    """
    print(f"Processing {len(event['Records'])} SQS messages")
    
    # Track failed message IDs for partial batch failure
    failed_message_ids = []
    
    # Collect all S3 paths from the batch
    s3_paths = []
    message_receipts = {}  # Track message receipt handles
    
    for record in event['Records']:
        try:
            # Parse SQS message
            message_body = json.loads(record['body'])
            message_id = record['messageId']
            receipt_handle = record['receiptHandle']
            message_receipts[message_id] = receipt_handle
            
            # Handle S3 event notification structure
            if 'Records' in message_body:
                for s3_record in message_body['Records']:
                    if 's3' in s3_record:
                        key = s3_record['s3']['object']['key']
                        s3_paths.append(key)
                        print(f"Collected S3 path: {key}")
            
        except Exception as e:
            print(f"Error parsing message {record.get('messageId', 'unknown')}: {str(e)}")
            failed_message_ids.append(record['messageId'])
    
    if not s3_paths:
        print("No valid S3 paths found in batch")
        return {
            'batchItemFailures': [
                {'itemIdentifier': msg_id} for msg_id in failed_message_ids
            ]
        }
    
    # Process paths based on invalidation mode
    invalidation_paths = process_paths(s3_paths)
    
    if not invalidation_paths:
        print("No invalidation paths generated")
        return {'batchItemFailures': []}
    
    # Create CloudFront invalidation with retry
    success = create_invalidation_with_retry(invalidation_paths)
    
    if not success:
        # If invalidation failed, mark all messages as failed
        failed_message_ids.extend([
            msg_id for msg_id in message_receipts.keys() 
            if msg_id not in failed_message_ids
        ])
    
    # Return partial batch failure response
    return {
        'batchItemFailures': [
            {'itemIdentifier': msg_id} for msg_id in failed_message_ids
        ]
    }


def process_paths(s3_paths: List[str]) -> Set[str]:
    """
    Process S3 paths based on invalidation mode.
    """
    invalidation_paths = set()
    
    if INVALIDATION_MODE == 'direct':
        # Direct mode: use S3 keys as CloudFront paths
        for path in s3_paths:
            cf_path = f"/{path}" if not path.startswith('/') else path
            invalidation_paths.add(cf_path)
    
    else:  # custom mode
        # Apply regex mappings
        for path in s3_paths:
            matched = False
            for mapping in PATH_MAPPINGS:
                pattern = mapping.get('source_pattern', '')
                inv_paths = mapping.get('invalidation_paths', [])
                
                try:
                    if re.match(pattern, path):
                        invalidation_paths.update(inv_paths)
                        matched = True
                        print(f"Path '{path}' matched pattern '{pattern}', adding: {inv_paths}")
                        break
                except re.error as e:
                    print(f"Invalid regex pattern '{pattern}': {str(e)}")
            
            if not matched and INVALIDATION_MODE == 'custom':
                print(f"No mapping found for path: {path}")
    
    # Optimize paths
    optimized_paths = optimize_invalidation_paths(invalidation_paths)
    
    return optimized_paths


def optimize_invalidation_paths(paths: Set[str]) -> Set[str]:
    """
    Optimize invalidation paths to reduce costs and improve efficiency.
    """
    paths_list = list(paths)
    
    # If /* is present, it invalidates everything
    if '/*' in paths_list:
        return {'/*'}
    
    # Group paths by directory and use wildcards if beneficial
    path_groups = {}
    for path in paths_list:
        if '/' in path:
            directory = path.rsplit('/', 1)[0]
            if directory not in path_groups:
                path_groups[directory] = []
            path_groups[directory].append(path)
    
    optimized = set()
    for directory, dir_paths in path_groups.items():
        # If more than 10 files in same directory, use wildcard
        if len(dir_paths) > 10:
            optimized.add(f"{directory}/*")
        else:
            optimized.update(dir_paths)
    
    # Handle root level paths
    root_paths = [p for p in paths_list if '/' not in p.strip('/')]
    if len(root_paths) > 10:
        optimized.add('/*')
    else:
        optimized.update(root_paths)
    
    print(f"Optimized {len(paths)} paths to {len(optimized)} paths")
    return optimized


def create_invalidation_with_retry(paths: Set[str]) -> bool:
    """
    Create CloudFront invalidation with exponential backoff retry.
    """
    paths_list = list(paths)
    
    # CloudFront limits: max 3000 paths per invalidation
    if len(paths_list) > 3000:
        print(f"Warning: {len(paths_list)} paths exceeds limit, using wildcard /*")
        paths_list = ['/*']
    
    retry_count = 0
    backoff_base = 2
    
    while retry_count < MAX_RETRIES:
        try:
            response = cloudfront.create_invalidation(
                DistributionId=DISTRIBUTION_ID,
                InvalidationBatch={
                    'Paths': {
                        'Quantity': len(paths_list),
                        'Items': paths_list
                    },
                    'CallerReference': f"invalidation-{int(time.time())}"
                }
            )
            
            invalidation_id = response['Invalidation']['Id']
            print(f"Successfully created invalidation {invalidation_id} with {len(paths_list)} paths")
            
            # Log the paths for debugging
            print(f"Invalidated paths: {json.dumps(sorted(paths_list))}")
            
            return True
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            error_message = e.response['Error']['Message']
            
            if error_code == 'TooManyInvalidationsInProgress':
                # CloudFront allows max 15 concurrent invalidations
                print(f"Too many invalidations in progress, retry {retry_count + 1}/3")
            elif error_code == 'AccessDenied':
                print(f"Access denied to create invalidation: {error_message}")
                return False  # Don't retry permission errors
            else:
                print(f"CloudFront error: {error_code} - {error_message}")
            
            retry_count += 1
            if retry_count < MAX_RETRIES:
                sleep_time = backoff_base ** retry_count
                print(f"Sleeping {sleep_time} seconds before retry...")
                time.sleep(sleep_time)
        
        except Exception as e:
            print(f"Unexpected error creating invalidation: {str(e)}")
            retry_count += 1
            if retry_count < MAX_RETRIES:
                sleep_time = backoff_base ** retry_count
                time.sleep(sleep_time)
    
    print(f"Failed to create invalidation after 3 retries")
    return False