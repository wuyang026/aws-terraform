# Define Local Values in Terraform
locals {
  name                    = "${var.instance_name}-${var.environment}"
  ec2_sg_name             = "${local.name}-terr-sg"

  common_tags = {
    owners      = var.instance_name
    environment = var.environment
    Terraform   = "true"
  }
} 