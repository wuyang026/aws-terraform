#########################################
# 1. IAM Roleを作成（role_name と policy_arns が設定されている場合のみ）
#########################################
resource "aws_iam_role" "role" {
  for_each = {
    for r in var.sa_roles : r.sa_name => r
    if(
      contains(keys(r), "role_name") &&
      r.role_name != null &&
      r.policy_arns != null &&
      length(r.policy_arns) > 0
    )
  }

  name = each.value.role_name

  # EKS Pod Identity 用 AssumeRolePolicy
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
# 2. IAM Policy を Role にアタッチ
#########################################
locals {
  role_policy_map = flatten([
    for r in var.sa_roles :
    contains(keys(r), "role_name") && r.role_name != null && r.policy_arns != null
    ? [
        for p in r.policy_arns : {
          sa_name    = r.sa_name
          policy_arn = p
        }
      ]
    : []
  ])
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = {
    for rp in local.role_policy_map :
    "${rp.sa_name}-${replace(rp.policy_arn, "[:/]", "-")}" => rp
  }

  role       = aws_iam_role.role[each.value.sa_name].name
  policy_arn = each.value.policy_arn
}

#########################################
# 3. ServiceAccount を作成（sa_exists = false の場合のみ）
#########################################
resource "kubernetes_service_account_v1" "sa" {
  for_each = {
    for r in var.sa_roles :
    r.sa_name => r if r.sa_exists == false
  }

  metadata {
    name      = each.value.sa_name
    namespace = each.value.namespace

    annotations = {
      # IAM Role は作成されたものを優先し、なければ外部提供の role_arn を使用
      "eks.amazonaws.com/role-arn" =
        lookup(aws_iam_role.role, each.key, null) != null
        ? aws_iam_role.role[each.key].arn
        : each.value.role_arn
    }
  }
}

#########################################
# 4. EKS Pod Identity Association（常に作成）
#########################################
resource "aws_eks_pod_identity_association" "this" {
  for_each = {
    for r in var.sa_roles : r.sa_name => r
  }

  cluster_name     = data.terraform_remote_state.eks.outputs.cluster_name
  namespace        = each.value.namespace
  service_account  = each.value.sa_name

  # IAM Role は作成されたものを優先
  role_arn = lookup(aws_iam_role.role, each.key, null) != null ? aws_iam_role.role[each.key].arn : each.value.role_arn
}