# EKSアドオンのインストール時に異常が発生しないように、自動で削除されるPodを作成し、ノードを起動
resource "kubectl_manifest" "sample_pod" {
  yaml_body = file("${path.module}/node_file/sample_pod.yaml")
  depends_on = [kubectl_manifest.karpenter_node_pool]
}

# ノードの起動が完了するまで待機
resource "time_sleep" "node_create" {
  depends_on = [kubectl_manifest.sample_pod]
  create_duration = "60s"
}

# EFS CSIドライバーインストール
module "aws_efs_csi_pod_identity" {
  #source  = "terraform-aws-modules/eks-pod-identity/aws"
  #version = "2.0.0"

  #sourceローカル化
  source = "./modules/aws_efs_csi_pod_identity/"

  name             = "${module.eks.cluster_name}-efs-role"
  additional_policy_arns = {
    AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }
  depends_on = [time_sleep.node_create]
}

resource "aws_eks_pod_identity_association" "efs_csi" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"
  role_arn        =  module.aws_efs_csi_pod_identity.iam_role_arn
  depends_on = [module.aws_efs_csi_pod_identity.iam_role_arn]
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = data.aws_eks_addon_version.efs_csi.version
  service_account_role_arn = module.aws_efs_csi_pod_identity.iam_role_arn
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name = "efs-csi-addon"
  }
  depends_on = [aws_eks_pod_identity_association.efs_csi]
}

# AWS CloudWatch Observability
module "aws_cloudwatch_observability_pod_identity" {
  #source = "terraform-aws-modules/eks-pod-identity/aws"

  #sourceローカル化
  source = "./modules/aws_efs_csi_pod_identity/"

  name = "${module.eks.cluster_name}-cloudwatch-observability-role"

  additional_policy_arns = {
      CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      AWSXrayWriteOnlyAccess      = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  }
  depends_on = [time_sleep.node_create]
}

resource "aws_eks_pod_identity_association" "cloudwatch_observability" {
  cluster_name    = module.eks.cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-observability-sa"
  role_arn        =  module.aws_cloudwatch_observability_pod_identity.iam_role_arn
  depends_on = [module.aws_cloudwatch_observability_pod_identity.iam_role_arn]
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "amazon-cloudwatch-observability"
  addon_version            = data.aws_eks_addon_version.cloudwatch_observability.version
  service_account_role_arn = module.aws_cloudwatch_observability_pod_identity.iam_role_arn
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name = "cloudwatch_observability-addon"
  }
  depends_on = [aws_eks_pod_identity_association.cloudwatch_observability]
}