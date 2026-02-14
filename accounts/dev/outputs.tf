output "backend_configuration" {
  description = "Copy this to your infrastructure projects"
  value       = <<-EOT
    # Add this to your Terraform configuration:

    terraform {
      backend "s3" {
        bucket         = "${module.terraform_backend.state_bucket_name}"
        key            = "{region}/{layer}/terraform.tfstate"  # Replace with actual path
        region         = "${var.primary_region}"
        encrypt        = true
        dynamodb_table = "${module.terraform_backend.lock_table_name}"
      }
    }
  EOT
}

output "state_bucket" {
  description = "S3 bucket for Terraform state"
  value       = module.terraform_backend.state_bucket_name
}

output "lock_table" {
  description = "DynamoDB table for state locking"
  value       = module.terraform_backend.lock_table_name
}

output "iam_policy_arn" {
  description = "IAM policy ARN for state access (attach to CI/CD roles)"
  value       = module.terraform_backend.iam_policy_arn
}
