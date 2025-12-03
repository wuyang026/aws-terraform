#########################################
# 1. IAM Roleを作成（role_nameが定義され、policy_arnsがある場合のみ作成）
#########################################
resource "aws_iam_role" "role" {
  for_each = {
    for r in var.sa_roles : r.sa_name => r
    if contains(keys(r), "role_name") && r.role_name != null && r.policy_arns != null && length(r.policy_arns) > 0
  }

  name = each.value.role_name

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
# 2. IAM PolicyをRoleにアタッチ（role_nameがある場合のみ）
#########################################
locals {
  role_policy_map = flatten([
    for r in var.sa_roles : contains(keys(r), "role_name") && r.role_name != null && r.policy_arns != null ? [
      for p in r.policy_arns : {
        sa_name    = r.sa_name
        policy_arn = p
      }
    ] : []
  ])
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = { for rp in local.role_policy_map : "${rp.sa_name}-${replace(rp.policy_arn, "[:/]", "-")}" => rp }

  role       = aws_iam_role.role[each.value.sa_name].name
  policy_arn = each.value.policy_arn
}

#########################################
# 3. Kubernetes ServiceAccountの存在チェック
#########################################
data "external" "sa_exists" {
  for_each = { for r in var.sa_roles : r.sa_name => r }

  program = ["bash", "-c", <<EOT
if kubectl get sa ${each.value.sa_name} -n ${each.value.namespace} >/dev/null 2>&1; then
  echo '{"exists":"true"}'
else
  echo '{"exists":"false"}'
fi
EOT
  ]
}

locals {
  sa_exists_map = {
    for r in var.sa_roles :
    r.sa_name => data.external.sa_exists[r.sa_name].result.exists
  }
}

#########################################
# 4. 存在しないServiceAccountのみ作成
#########################################
resource "kubernetes_service_account_v1" "sa" {
  for_each = {
    for r in var.sa_roles :
    r.sa_name => r if local.sa_exists_map[r.sa_name] == "false"
  }

  metadata {
    name      = each.value.sa_name
    namespace = each.value.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = lookup(aws_iam_role.role, each.key, null) != null ? aws_iam_role.role[each.key].arn : each.value.role_arn
    }
  }
}

#########################################
# 5. EKS Pod Identity Associationを作成
#########################################
resource "aws_eks_pod_identity_association" "this" {
  for_each = { for r in var.sa_roles : r.sa_name => r }

  cluster_name     = data.terraform_remote_state.eks.outputs.cluster_name
  namespace        = each.value.namespace
  service_account  = each.value.sa_name
  role_arn         = lookup(aws_iam_role.role, each.key, null) != null ? aws_iam_role.role[each.key].arn : each.value.role_arn
}