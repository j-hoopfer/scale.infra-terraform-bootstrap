  # Terraform Bootstrap

  **Purpose:** One-time setup to create Terraform state infrastructure (S3 + DynamoDB) for Dev and Prod AWS accounts.

  ## Overview

  This repository solves the "chicken and egg" problem:
  - **Problem:** You need an S3 bucket to store Terraform state
  - **Solution:** Run this bootstrap project with local state once per account

  After bootstrap, all other infrastructure projects use the remote S3 backend.

  ## Repository Structure

  mycompany.infra-terraform-bootstrap/
  ├── modules/terraform-state-backend/ # Reusable module
  └── accounts/ # Account-specific configs
  ├── dev/
  └── prod/
