# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "invalidation_lambda" {
  count = var.enable_cache_invalidation ? 1 : 0

  name              = "/aws/lambda/${var.cloudfront_distribution_name}-invalidation"
  retention_in_days = try(var.invalidation_lambda_config.log_retention_days, 7)

  tags = var.tags
}

# IAM Role for Lambda
resource "aws_iam_role" "invalidation_lambda" {
  count = var.enable_cache_invalidation ? 1 : 0

  name = "${var.cloudfront_distribution_name}-invalidation-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "invalidation_lambda" {
  count = var.enable_cache_invalidation ? 1 : 0

  name = "${var.cloudfront_distribution_name}-invalidation-lambda-policy"
  role = aws_iam_role.invalidation_lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.invalidation_lambda[0].arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:DeleteMessageBatch",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.invalidation_queue[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Resource = aws_cloudfront_distribution.this.arn
      }
    ]
  })
}


# Lambda function
resource "aws_lambda_function" "invalidation" {
  count = var.enable_cache_invalidation ? 1 : 0

  filename                       = data.archive_file.lambda_zip[0].output_path
  function_name                  = "${var.cloudfront_distribution_name}-invalidation"
  role                           = aws_iam_role.invalidation_lambda[0].arn
  handler                        = "index.handler"
  runtime                        = "python3.11"
  memory_size                    = try(var.invalidation_lambda_config.memory_size, 128)
  timeout                        = try(var.invalidation_lambda_config.timeout, 300)
  reserved_concurrent_executions = try(var.invalidation_lambda_config.reserved_concurrency, 1)

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.this.id
      INVALIDATION_MODE          = var.invalidation_mode
      PATH_MAPPINGS              = jsonencode(var.invalidation_path_mappings)
    }
  }

  depends_on = [
    aws_iam_role_policy.invalidation_lambda,
    aws_cloudwatch_log_group.invalidation_lambda
  ]

  tags = var.tags
}

# Lambda event source mapping from SQS
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  count = var.enable_cache_invalidation ? 1 : 0

  event_source_arn                   = aws_sqs_queue.invalidation_queue[0].arn
  function_name                      = aws_lambda_function.invalidation[0].arn
  batch_size                         = try(var.invalidation_sqs_config.batch_size, 100)
  maximum_batching_window_in_seconds = try(var.invalidation_sqs_config.batch_window_seconds, 60)
  function_response_types            = ["ReportBatchItemFailures"]
  scaling_config {
    maximum_concurrency = 2
  }
}

# Archive file for Lambda deployment
data "archive_file" "lambda_zip" {
  count = var.enable_cache_invalidation ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/lambda_code/cache_invalidation"
  output_path = "${path.module}/lambda_function.zip"
}
