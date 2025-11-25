resource "aws_eks_access_entry" "eks_access" {
  for_each      = { for p in var.principals : p.arn => p }
  cluster_name  = var.cluster_name
  principal_arn = each.value.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_access_policy" {
  for_each = {
    for p in var.principals :
    p.arn => p if length(p.access_policies) > 0
  }

  cluster_name      = var.cluster_name
  principal_arn     = each.value.arn
  policy_arn        = each.value.access_policies[0]
  access_scope {
    type = length(each.value.namespaces) > 0 ? "namespace" : "cluster"
    namespaces = length(each.value.namespaces) > 0 ? each.value.namespaces : null
  }
}
