# Terraform Bootstrap

**Purpose:** One-time setup to create Terraform state infrastructure (S3 + DynamoDB) for Dev and Prod AWS accounts.

## Overview

This repository solves the "chicken and egg" problem:

- **Problem:** You need an S3 bucket to store Terraform state
- **Solution:** Run this bootstrap project with local state once per account

After bootstrap, all other infrastructure projects use the remote S3 backend.

## Repository Structure

```
mycompany.infra-terraform-bootstrap/
├── modules/terraform-state-backend/ # Reusable module
└── accounts/ # Account-specific configs
   ├── dev/
   └── prod/
```

## Why terraform.tfvars Files Are Committed

**This repository intentionally commits `terraform.tfvars` since it contain no secrets**

- ✅ AWS Account IDs (not secret - visible in AWS Console)
- ✅ Environment names (dev, prod)
- ✅ Region names (us-east-1)
- ✅ Company name prefix

## Modules

### Terraform State Backend (`modules/terraform-state-backend`)

Creates S3 bucket and DynamoDB table for Terraform remote state storage.

#### Features

- S3 bucket with versioning enabled
- Server-side encryption (AES256 or KMS)
- Public access blocked
- Lifecycle policy (deletes old versions after 90 days)
- DynamoDB table for state locking (on-demand billing)
- IAM policy for CI/CD access

#### Usage Example

```hcl
module "terraform_backend" {
  source = "../../modules/terraform-state-backend"

  bucket_name     = "mycompany-terraform-state-dev"
  lock_table_name = "mycompany-terraform-locks"
  environment     = "dev"

  common_tags = {
    ManagedBy  = "Terraform"
    Repository = "mycompany.infra-terraform-bootstrap"
  }
}
```

#### Outputs

- `state_bucket_name` - S3 bucket name
- `lock_table_name` - DynamoDB table name
- `iam_policy_arn` - IAM policy ARN for CI/CD
- `backend_config` - Complete backend configuration
