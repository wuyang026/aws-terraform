data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "external" "config_exists" {
  program = ["bash", "${path.module}/config_check/check_config.sh", var.aws_region]
}