module "terraform_backend" {
  source = "../../modules/terraform-state-backend"

  bucket_name     = "${var.name}-terraform-state-${var.environment}"
  lock_table_name = "terraform-locks-${var.environment}"
  environment     = var.environment

  common_tags = {
    ManagedBy   = "Terraform"
    Repository  = "infra-terraform-bootstrap"
    Environment = var.environment
    AccountID   = var.aws_account_id
  }
}
