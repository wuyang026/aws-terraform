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

  # cloudwatch log groups → s3
  # cloudwatch ログ保存期間 retention設定値(1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653)日
  # 最大10年
  log_groups = [
    { name = "/aws/containerinsights/${local.cluster_name}/application", retention = 30 },
    { name = "/aws/containerinsights/${local.cluster_name}/dataplane", retention = 30 },
    { name = "/aws/containerinsights/${local.cluster_name}/host", retention = 30 },
    { name = "/aws/containerinsights/${local.cluster_name}/performance", retention = 30 },
    { name = "/aws/eks/${local.cluster_name}/cluster", retention = 30 },
  ]
} 