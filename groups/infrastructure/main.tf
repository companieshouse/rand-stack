provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
  }
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
  }
}

resource "aws_acm_certificate" "certificate" {
  domain_name = local.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.environment
  }
}

resource "aws_route53_record" "route" {
  name    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.hosted_zone.id
  records = [aws_acm_certificate.certificate.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

module "alb" {
  source = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.205"

  environment         = var.environment
  service             = local.service_name
  ssl_certificate_arn = aws_acm_certificate.certificate.arn
  subnet_ids          = data.aws_subnets.private.subnet_ids
  vpc_id              = data.aws_vpc.vpc.id

  create_security_group  = true
  
  ingress_prefix_lists   = local.asg_ingress_prefix_list
  redirect_http_to_https = true
  service_configuration = {
    default = {
      listener_config = {
        default_action_type = "fixed-response"
        port                = 443
      }
    }
  }
}

resource "aws_ecs_cluster" "rand" {
  name = "${local.name_prefix}-stack"
}

resource "aws_ssm_parameter" "rand_domain" {
  name = "/${local.name_prefix}/domain"
  type = "SecureString"
  value = local.domain_name
}
