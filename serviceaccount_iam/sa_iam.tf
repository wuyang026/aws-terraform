#########################################
# IAM Role（EKS Pod Identity 用）
#########################################
# ServiceAccount に対応する IAM Role を作成
# ※これは IRSA ではなく、EKS Pod Identity 専用の AssumeRole 設定
resource "aws_iam_role" "role" {
  for_each = { for r in var.sa_roles : r.role_name => r }

  name = each.value.role_name

  # EKS Pod がこの IAM Role を引き受けるためのポリシー
  # Principal.Service = "pods.eks.amazonaws.com" は Pod Identity 専用
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:TagSession",
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

#########################################
# Role × Policy の組み合わせをフラット化
#########################################
locals {
  role_policy_map = flatten([
    for r in var.sa_roles : [
      for p in r.policy_arns : {
        role_name  = r.role_name
        policy_arn = p
      }
    ]
  ])
}

#########################################
# IAM Policy を Role にアタッチ
#########################################
# 既存の IAM Policy を IAM Role に紐付ける
resource "aws_iam_role_policy_attachment" "attach" {
  for_each = { for rp in local.role_policy_map : "${rp.role_name}-${replace(rp.policy_arn, "[:/]", "-")}" => rp }

  role       = aws_iam_role.role[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

#########################################
# ServiceAccount 定義の Map
#########################################
locals {
  sa_map = { for r in var.sa_roles : r.role_name => r }
}

#########################################
# Kubernetes ServiceAccount を作成
#########################################
# ※Pod Identity の場合、annotation は必須ではないが残しても問題なし
resource "kubernetes_service_account_v1" "sa" {
  for_each = local.sa_map

  metadata {
    name      = each.value.sa_name
    namespace = each.value.namespace

    annotations = {
      # IRSA と互換性のために残す（Pod Identity の場合は実際には使用されない）
      "eks.amazonaws.com/role-arn" = aws_iam_role.role[each.key].arn
    }
  }
}

#########################################
# EKS Pod Identity Association（最重要）
#########################################
# Pod と IAM Role を正式に紐付ける設定
# これを作らないと Pod Identity は動作しない
resource "aws_eks_pod_identity_association" "this" {
  for_each = local.sa_map

  cluster_name     = data.terraform_remote_state.eks.outputs.cluster_name      # EKS クラスター名
  namespace        = each.value.namespace   # ServiceAccount の Namespace
  service_account  = each.value.sa_name     # ServiceAccount 名
  role_arn         = aws_iam_role.role[each.key].arn
}