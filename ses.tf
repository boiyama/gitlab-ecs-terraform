# Create SES Domain Identity for certificate validation
resource "aws_ses_domain_identity" "main" {
  domain = "${var.domain_name}"
}
