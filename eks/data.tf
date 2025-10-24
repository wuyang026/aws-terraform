# efs_csiバージョン取得
data "aws_eks_addon_version" "efs_csi" {
  addon_name   = "aws-efs-csi-driver"
  kubernetes_version = module.eks.cluster_version
  most_recent  = true
}

data "aws_eks_addon_version" "cloudwatch_observability" {
  addon_name          = "amazon-cloudwatch-observability"
  kubernetes_version  = module.eks.cluster_version
  most_recent         = true
}