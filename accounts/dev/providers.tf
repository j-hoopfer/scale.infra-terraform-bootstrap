terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # NOTE: No backend configured - uses local state for bootstrap
  # After creation, you can optionally migrate this to use the remote backend
}

provider "aws" {
  region = var.primary_region

  # Uncomment if using AWS SSO profile
  # profile = "mycompany-dev"
}
