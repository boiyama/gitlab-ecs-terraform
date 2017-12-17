provider "aws" {}

# Get current AWS account
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {
  current = true
}
