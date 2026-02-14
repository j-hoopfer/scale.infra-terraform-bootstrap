variable "name" {
  description = "Primary AWS region for state storage"
  type        = string
  default     = "mycompany"
}

variable "aws_account_id" {
  description = "AWS Account ID for Dev environment"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be exactly 12 digits."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "primary_region" {
  description = "Primary AWS region for state storage"
  type        = string
  default     = "us-east-1"
}
