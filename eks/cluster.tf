module "eks" {
  #source  = "terraform-aws-modules/eks/aws"
  #version = "~> 21.1"
  
  #sourceローカル化
  source = "./modules/eks"

  kubernetes_version = var.cluster_k8s_version
  name    = local.cluster_name

  endpoint_public_access                   = true
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  create_auto_mode_iam_resources           = true

  # kms無効
  create_kms_key = false
  encryption_config = null

  compute_config = {
    enabled    = true
  }

  vpc_id                    = var.existing_vpc_id
  subnet_ids                = data.aws_subnets.private_subnets.ids

  # cluster security group指定
  create_security_group = false
  additional_security_group_ids = [aws_security_group.eks_cluster_sg.id]

  # node security group自動作成不要、node classにカスタムsgを指定
  create_node_security_group = false

  # パブリックアクセス指定
  endpoint_public_access_cidrs = length(var.endpoint_public_access_cidrs) > 0 ? var.endpoint_public_access_cidrs : ["0.0.0.0/0"]

  cloudwatch_log_group_retention_in_days = 30

  tags = local.common_tags

  depends_on = [aws_security_group.eks_cluster_sg,aws_security_group.eks_node_sg]
}
