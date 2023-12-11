resource "aws_ecs_cluster" "rand" {
  name = "${local.name_prefix}-stack"
}
