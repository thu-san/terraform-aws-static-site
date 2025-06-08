# Static Site with Cache Invalidation Example

This example demonstrates how to use the AWS Static Site module with automatic CloudFront cache invalidation triggered by S3 file uploads.

## Features Demonstrated

### 1. Direct Mode

- Invalidates the exact CloudFront path matching the uploaded S3 object
- Simple configuration with no path mappings required
- Best for straightforward static sites

### 2. Custom Mode

- Uses regex patterns to map S3 paths to CloudFront invalidation paths
- Allows wildcards and multiple invalidation paths per upload
- Ideal for complex sites with specific caching strategies

### 3. Dead Letter Queue (DLQ)

- Captures failed invalidation attempts for debugging
- Helps monitor and troubleshoot issues
- Essential for production deployments

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## How It Works

1. **File Upload**: When files are uploaded to the S3 bucket
2. **S3 Event**: S3 sends an event notification to the SQS queue
3. **Batching**: SQS collects events for the configured batch window (30-60 seconds)
4. **Lambda Processing**: Lambda function processes the batch:
   - Direct mode: Uses S3 key as CloudFront path
   - Custom mode: Applies regex mappings to determine paths
5. **Invalidation**: Creates CloudFront invalidation with deduplicated paths
6. **Monitoring**: Failed invalidations go to DLQ (if configured)

## Path Mapping Examples

### Custom Mode Mappings

```hcl
# Images: Any image upload invalidates all images
"^images/.*" → ["/images/*"]

# CSS: CSS changes invalidate CSS folder and homepage
"^css/.*\.css$" → ["/css/*", "/*"]

# Homepage: Index.html changes invalidate multiple paths
"^(index\.html|home\.html)$" → ["/*", "/index.html", "/home.html"]
```

## Monitoring

### CloudWatch Logs

- Lambda function logs all invalidation activities
- Use the `lambda_log_group_arn` output to access logs

### SQS Metrics

- Monitor queue depth to ensure timely processing
- Check DLQ for failed messages

### Example Log Query

```
fields @timestamp, @message
| filter @message like /invalidation/
| sort @timestamp desc
| limit 20
```

## Cost Optimization

1. **Batching**: Processes multiple files in one Lambda invocation
2. **Path Optimization**: Converts multiple specific paths to wildcards
3. **Reserved Concurrency**: Limits parallel Lambda executions
4. **Efficient Memory**: Uses only required memory (256-512MB)

## Testing

1. Upload a single file:

   ```bash
   aws s3 cp test.html s3://your-bucket-name/
   ```

2. Upload multiple files:

   ```bash
   aws s3 sync ./local-folder s3://your-bucket-name/
   ```

3. Monitor CloudWatch Logs for invalidation details

## Cleanup

```bash
terraform destroy
```

## Notes

- First 1,000 CloudFront invalidation paths per month are free
- Lambda costs are minimal due to batching
- SQS costs are negligible for typical usage
- Configure batch window based on your update frequency
