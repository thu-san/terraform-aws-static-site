# SQS Queue for S3 event batching
resource "aws_sqs_queue" "invalidation_queue" {
  count = var.enable_cache_invalidation ? 1 : 0

  name                       = "${var.cloudfront_distribution_name}-invalidation-queue"
  message_retention_seconds  = try(var.invalidation_sqs_config.message_retention_days, 4) * 24 * 60 * 60
  visibility_timeout_seconds = try(var.invalidation_sqs_config.visibility_timeout, 300)
  receive_wait_time_seconds  = 20 # Long polling

  redrive_policy = var.invalidation_dlq_arn != "" ? jsonencode({
    deadLetterTargetArn = var.invalidation_dlq_arn
    maxReceiveCount     = 3
  }) : null

  tags = var.tags
}

# SQS Queue Policy to allow S3 to send messages
resource "aws_sqs_queue_policy" "invalidation_queue_policy" {
  count = var.enable_cache_invalidation ? 1 : 0

  queue_url = aws_sqs_queue.invalidation_queue[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.invalidation_queue[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.this.arn
          }
        }
      }
    ]
  })
}