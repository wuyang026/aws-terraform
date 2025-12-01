#########################################
# IAM Role（EKS Pod Identity 用）
# policy_arns がある場合のみ作成
#########################################
resource "aws_iam_role" "role" {
  for_each = { for r in var.sa_roles : r.role_name => r if r.policy_arns != null && length(r.policy_arns) > 0 }

  name = each.value.role_name

  # EKS Pod がこの IAM Role を引き受けるためのポリシー
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
# Role × Policy の組み合わせをフラット化（policy_arns がある場合のみ）
#########################################
locals {
  role_policy_map = flatten([
    for r in var.sa_roles : r.policy_arns != null ? [
      for p in r.policy_arns : {
        role_name  = r.role_name
        policy_arn = p
      }
    ] : []
  ])
}

#########################################
# IAM Policy を Role にアタッチ（policy_arns がある場合のみ）
#########################################
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
resource "kubernetes_service_account_v1" "sa" {
  for_each = local.sa_map

  metadata {
    name      = each.value.sa_name
    namespace = each.value.namespace

    annotations = {
      # IRSA / Pod Identity 互換
      # IAM Role を作成した場合は aws_iam_role.role[each.key].arn を使用
      # それ以外は既存の role_name を直接使用
      "eks.amazonaws.com/role-arn" = lookup(
        aws_iam_role.role, each.key, null
      ) != null ? aws_iam_role.role[each.key].arn : each.value.role_name
    }
  }
}

#########################################
# EKS Pod Identity Association
#########################################
resource "aws_eks_pod_identity_association" "this" {
  for_each = local.sa_map

  cluster_name     = data.terraform_remote_state.eks.outputs.cluster_name
  namespace        = each.value.namespace
  service_account  = each.value.sa_name
  # IAM Role が作成された場合は arn を使用、それ以外は既存の role_name を使用
  role_arn         = lookup(aws_iam_role.role, each.key, null) != null ? aws_iam_role.role[each.key].arn : each.value.role_name
}