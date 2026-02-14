# Terraform Bootstrap

**Purpose:** One-time setup to create Terraform state infrastructure (S3 + DynamoDB) for Dev and Prod AWS accounts.

## Overview

This repository solves the "chicken and egg" problem:

- **Problem:** You need an S3 bucket to store Terraform state
- **Solution:** Run this bootstrap project with local state once per account

After bootstrap, all other infrastructure projects use the remote S3 backend.

## Repository Structure

```
scale.infra-terraform-bootstrap/
├── .github/
│   └── workflows/
│       ├── validate.yml          # Terraform fmt/validate + docs
│       ├── security.yml          # tfsec security scanning
│       └── lint.yml              # tflint code quality
├── modules/
│   └── terraform-state-backend/  # Reusable module
│       ├── s3.tf                 # S3 bucket for state storage
│       ├── dynamodb.tf           # DynamoDB for state locking
│       ├── iam.tf                # IAM policies for access
│       ├── variables.tf
│       └── outputs.tf
└── accounts/                     # Account-specific configs
    ├── dev/
    │   ├── main.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars      # Committed (no secrets)
    └── prod/
        ├── main.tf
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tfvars      # Committed (no secrets)
```

## AWS Accounts

| Environment | Account ID | S3 Bucket                  | DynamoDB Table       | Region    | Status                                          |
| ----------- | ---------- | -------------------------- | -------------------- | --------- | ----------------------------------------------- |
| Dev         | TBD        | scale-terraform-state-dev  | terraform-locks-dev  | us-east-1 | ✅ Live Bootstrap complete, CI workflows active |
| Prod        | TBD        | scale-terraform-state-prod | terraform-locks-prod | us-east-1 | 🚧 Pending                                      |

## CI/CD Workflows

This repository uses separate workflow files for different concerns:

- **[validate.yml](.github/workflows/validate.yml)** - Terraform format, syntax validation, and documentation checks
- **[security.yml](.github/workflows/security.yml)** - tfsec security scanning (runs on PRs and nightly)
- **[lint.yml](.github/workflows/lint.yml)** - tflint code quality checks

All workflows run on pull requests to validate changes before merge.

## Why terraform.tfvars Files Are Committed

**This repository intentionally commits `terraform.tfvars` files since they contain no secrets:**

- ✅ AWS Account IDs (not secret - visible in AWS Console)
- ✅ Environment names (dev, prod)
- ✅ Region names (us-east-1)
- ✅ Company name prefix

**Why this is safe:**

- Account IDs are public information within your organization
- No AWS credentials, API keys, or passwords are stored
- Single source of truth for team (no configuration drift)
- CI/CD validates all changes before deployment

**For infrastructure projects** (NOT this bootstrap), exclude `.tfvars` files since they may contain secrets.

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

  bucket_name     = "scale-terraform-state-dev"
  lock_table_name = "terraform-locks-dev"
  environment     = "dev"

  common_tags = {
    ManagedBy  = "Terraform"
    Repository = "scale.infra-terraform-bootstrap"
  }
}
```

#### Outputs

- `state_bucket_name` - S3 bucket name
- `lock_table_name` - DynamoDB table name
- `iam_policy_arn` - IAM policy ARN for CI/CD
- `backend_config` - Complete backend configuration
