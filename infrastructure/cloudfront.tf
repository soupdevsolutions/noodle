resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for the ${local.app_name} distribution"
}

resource "aws_cloudfront_distribution" "noodle_cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.noodle_frontend.bucket_regional_domain_name
    origin_id   = "${local.app_name}-web-client-s3-origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai.id}"
    }
  }

  origin {
    domain_name = "${aws_apigatewayv2_api.api.id}.execute-api.${var.AWS_REGION}.amazonaws.com"
    origin_id   = "${local.app_name}-api-gateway-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"


  aliases = ["${local.domain_name}", "www.${local.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.app_name}-web-client-s3-origin"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.app_name}-api-gateway-origin"

    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # caching disabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = aws_acm_certificate.grabnoodle.arn
    ssl_support_method             = "sni-only"
  }

  depends_on = [aws_s3_bucket.noodle_frontend]
}
