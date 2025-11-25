resource "aws_iam_role" "role" {
  for_each = { for r in var.roles : r.name => r }

  name = each.value.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "*" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = {
    for role in var.roles :
    "${role.name}-${index(role.policy_arns, policy)}" => {
      role_name  = role.name
      policy_arn = policy
    }
    for policy in role.policy_arns
  }

  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}

resource "kubernetes_service_account_v1" "sa" {
  for_each = aws_iam_role.role

  metadata {
    name      = each.value.sa_name
    namespace = each.value.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = each.value.arn
    }
  }
}