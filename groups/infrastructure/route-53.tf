resource "aws_acm_certificate" "certificate" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.environment
  }

  # This is recommended since this is attached to ALB listener§
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.id
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route : record.fqdn]
}

resource "aws_route53_record" "a_record" {
  allow_overwrite = true
  name            = local.domain_name
  type            = "A"
  zone_id         = data.aws_route53_zone.hosted_zone.id
  records         = [module.alb.application_load_balancer_dns_name]
  ttl             = 60
}
