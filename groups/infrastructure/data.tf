data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}-stack"
}

data "aws_acm_certificate" "cert" {
  domain = local.domain_name
}

data "aws_route53_zone" "hosted_zone" {
  name = local.hosted_zone_name
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    NetworkType = "private"
  }
}

data "aws_prefix_list" "admin" {
  name = local.admin_prefix_list_name
}
