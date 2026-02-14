
# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name                        = var.lock_table_name
  billing_mode                = "PAY_PER_REQUEST" # On-demand pricing
  hash_key                    = "LockID"
  deletion_protection_enabled = false

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    {
      Name        = var.lock_table_name
      Purpose     = "Terraform State Locking"
      Environment = var.environment
    }
  )
}
