module "alb" {
  source = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.205"

  environment         = var.environment
  service             = local.service_name
  ssl_certificate_arn = aws_acm_certificate.certificate.arn
  subnet_ids          = data.aws_subnets.private.ids
  vpc_id              = data.aws_vpc.vpc.id
  internal            = true

  create_security_group = true

  ingress_prefix_list_ids = local.alb_ingress_prefix_list
  ingress_cidrs           = local.alb_ingress_cidrs
  redirect_http_to_https  = true
  service_configuration = {
    default = {
      listener_config = {
        default_action_type = "fixed-response"
        port                = 443
        fixed_response = {
          message_body = "unauthorized"
          status_code  = 401
        }
      }
    }
  }
}
