#provider "aws" {}
provider "aws" {
  profile     = "mysaml"
  region      = "eu-west-2"
  max_retries = 11
}

# Get current AWS account
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}
