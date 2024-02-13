resource "aws_ssm_parameter" "rand_domain" {
  name   = "/${local.name_prefix}/domain"
  type   = "SecureString"
  value  = local.domain_name
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "rand_alb_name" {
  name   = "/${local.name_prefix}/alb_name"
  type   = "SecureString"
  value  = module.alb.application_load_balancer_name
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "rand_alb_sg" {
  name   = "/${local.name_prefix}/alb_security_group_id"
  type   = "SecureString"
  value  = module.alb.security_group_id
  key_id = data.aws_kms_key.kms_key.id
}


