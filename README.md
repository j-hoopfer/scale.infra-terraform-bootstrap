# Terraform Bootstrap

**Purpose:** One-time setup to create Terraform state infrastructure (S3 + DynamoDB) for Dev and Prod AWS accounts.

**Documentation:** See the [terraform-bootstrap-plan](../ec2-to-fargate-migration-docs/terraform-bootstrap-plan/) directory for complete setup instructions.

## Quick Start

If you're following the bootstrap plan, you're in the right place! This repository was created in:

- **Phase 1:** Repository Setup
- **Phase 2:** Terraform Module Creation
- **Phase 3:** Dev Account Bootstrap
- **Phase 4:** CI/CD Setup (validates code quality and security)
- **Phase 5:** Prod Account Bootstrap

## Overview

This repository solves the "chicken and egg" problem:

- **Problem:** You need an S3 bucket to store Terraform state
- **Solution:** Run this bootstrap project with local state once per account

After bootstrap, all other infrastructure projects use the remote S3 backend.

## Repository Structure

```
mycompany.infra-terraform-bootstrap/
├── .github/
│   └── workflows/
│       └── validate.yml          # CI/CD for code quality & security
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

| Environment | Account ID     | S3 Bucket                      | Region    |
| ----------- | -------------- | ------------------------------ | --------- |
| Dev         | (your-dev-id)  | mycompany-terraform-state-dev  | us-east-1 |
| Prod        | (your-prod-id) | mycompany-terraform-state-prod | us-east-1 |

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
