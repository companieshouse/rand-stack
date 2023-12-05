locals {
  service_name = "rand"
  stack_name = "rand"
  name_prefix = "${local.stack_name}-${var.environment}"

  stack_secrets             = jsondecode(data.vault_generic_secret.secrets.data_json)
  domain_name               = "${local.stack_name}.${local.hosted_zone_name}"

  vpc_name                  = local.stack_secrets["vpc_name"]
  admin_prefix_list_name    = local.stack_secrets["admin_prefix_list_name"]
  hosted_zone_name    = local.stack_secrets["hosted_zone_name"]
  asg_ingress_prefix_list   = [data.aws_prefix_list.admin.id]
}
