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

  node_configs = {
    nodepool_forntend = {
      node_class_name    = "${local.cluster_name}-frontend-nodeclass"
      private_subnet_ids = ["subnet-02728cb43841d0c6d", "subnet-023bc916f5ccaf069"]
      eks_node_sg_ids    = ["sg-0a76ba07092c608c1"]

      node_pool_name     = "${local.cluster_name}-frontend-nodepool"
      instance_cpu       = ["2", "4"]
      instance_category  = ["m","c","r"]
      instance_arch      = ["amd64"]
    },
    nodepool_backend = {
      node_class_name    = "${local.cluster_name}-backend-nodeclass"
      private_subnet_ids = ["subnet-0ad69bf299f445cbe"]
      eks_node_sg_ids    = ["sg-0a76ba07092c608c1"]

      node_pool_name     = "${local.cluster_name}-backend-nodepool"
      instance_cpu       = ["2", "4"]
      instance_category  = ["m","c","r"]
      instance_arch      = ["amd64"]
    }
  }
} 