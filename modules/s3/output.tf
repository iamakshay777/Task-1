output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.tfstate.id
}

output "lock_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.tf_locks.name
}
