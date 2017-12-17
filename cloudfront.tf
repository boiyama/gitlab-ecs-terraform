# Create distribution for ALB
resource "aws_cloudfront_distribution" "main" {
  enabled     = true
  comment     = "${var.project}-cloudfront"
  price_class = "PriceClass_200"
  aliases     = ["${formatlist("%s%s", var.cloudfront_hosts, var.domain_name)}"]

  viewer_certificate {
    acm_certificate_arn      = "${aws_cloudformation_stack.cert.outputs["Arn"]}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  logging_config {
    bucket = "${aws_s3_bucket.cloudfront.bucket_domain_name}"
  }

  origin {
    domain_name = "${aws_alb.main.dns_name}"
    origin_id   = "origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "origin"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0

    forwarded_values {
      headers      = ["*"]
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP", "US"]
    }
  }
}
