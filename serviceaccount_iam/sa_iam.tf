# ServiceAccount に対応する IAM Role を定義
resource "aws_iam_role" "role" {
  for_each = { for r in var.sa_roles : r.role_name => r }

  name = each.value.role_name

  # EKS Pod がこの Role を引き受けるためのポリシー（IRSA 用）
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

# Role × Policy の組み合わせをフラット化
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

# IAM Role に既存の Policy をアタッチ
resource "aws_iam_role_policy_attachment" "attach" {
  for_each = { for rp in local.role_policy_map : "${rp.role_name}-${replace(rp.policy_arn, "[:/]", "-")}" => rp }

  # Role が先に作成されることを保証
  role       = aws_iam_role.role[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

# ServiceAccount 用マッピングを作成
locals {
  sa_map = { for r in var.sa_roles : r.role_name => r }
}

# Kubernetes ServiceAccount を作成し、IAM Role ARN を注釈に設定
resource "kubernetes_service_account_v1" "sa" {
  for_each = local.sa_map

  metadata {
    name      = each.value.sa_name
    namespace = each.value.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.role[each.key].arn
    }
  }
}