resource "aws_acm_certificate" "grabnoodle" {
  domain_name               = local.domain_name
  subject_alternative_names = ["www.${local.domain_name}"]
  validation_method         = "DNS"

  provider = aws.us
}

resource "aws_acm_certificate_validation" "grabnoodle" {
  certificate_arn         = aws_acm_certificate.grabnoodle.arn
  validation_record_fqdns = [for record in aws_route53_record.grabnoodle : record.fqdn]

  provider = aws.us
}

resource "aws_acm_certificate" "grabnoodle_eu" {
  domain_name               = local.domain_name
  subject_alternative_names = ["www.${local.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "grabnoodle_eu" {
  certificate_arn         = aws_acm_certificate.grabnoodle_eu.arn
  validation_record_fqdns = [for record in aws_route53_record.grabnoodle : record.fqdn]
}
