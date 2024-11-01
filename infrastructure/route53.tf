data "aws_route53_zone" "grabnoodle" {
  name         = local.domain_name
  private_zone = false

  provider = aws.us
}

resource "aws_route53_record" "grabnoodle" {
  for_each = {
    for dvo in aws_acm_certificate.grabnoodle.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.grabnoodle.zone_id

  provider = aws.us
}

resource "aws_route53_record" "grabnoodle_alias" {
  name    = local.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.grabnoodle.id

  alias {
    name                   = aws_cloudfront_distribution.noodle_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.noodle_cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }

  provider = aws.us
}


resource "aws_route53_record" "grabnoodle_alias_www" {
  name    = "www.${local.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.grabnoodle.id

  alias {
    name                   = aws_cloudfront_distribution.noodle_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.noodle_cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }

  provider = aws.us
}

