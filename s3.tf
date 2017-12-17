# Create S3 Bucket for CloudFront
resource "aws_s3_bucket" "cloudfront" {
  bucket = "${var.project}-s3-cloudfront"

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

# Create S3 Bucket for GitLab backup
resource "aws_s3_bucket" "gitlab_backup" {
  bucket = "${var.project}-s3-gitlab-backup"

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

# Create S3 Bucket for GitLab Runner
resource "aws_s3_bucket" "gitlab_runner" {
  bucket = "${var.project}-s3-gitlab-runner"
}
