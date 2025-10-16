# Define Local Values in Terraform
locals {
  name                    = "${var.project_name}-${var.environment}"
  cluster_name            = "${local.name}-eks-cluster"
  node_class_name         = "${local.cluster_name}-nodeclass"
  node_pool_name          = "${local.cluster_name}-nodepool"
  cluster_sg_name         = "${local.cluster_name}-terr-sg"
  node_sg_name            = "${local.cluster_name}-node-terr-sg"

  common_tags = {
    owners      = var.project_name
    environment = var.environment
    Terraform   = "true"
  }
} 