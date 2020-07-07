# Get public hosted zone
data "aws_route53_zone" "public" {
  name         = "${var.domain_name}"
  private_zone = false
}

# Add record for SES Domain Identity verification
resource "aws_route53_record" "public_txt_ses" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "_amazonses.${data.aws_route53_zone.public.name}"
  type    = "TXT"
  ttl     = "1800"
  records = ["${aws_ses_domain_identity.main.verification_token}"]
}

# Add record for SES MX
resource "aws_route53_record" "public_mx_ses" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = data.aws_route53_zone.public.name
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
}

# Add record for CloudFront
resource "aws_route53_record" "public_a_cloudfront" {
  count   = length(var.cloudfront_hosts)
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.cloudfront_hosts[count.index]}${data.aws_route53_zone.public.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

# Add record for ALB
resource "aws_route53_record" "public_a_alb" {
  count   = length(var.alb_hosts)
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.alb_hosts[count.index]}${data.aws_route53_zone.public.name}"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = false
  }
}
