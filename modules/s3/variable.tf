variable "bucket_name" {
  description = "The name of the S3 bucket to store tfstate"
  type        = string
}

variable "lock_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
