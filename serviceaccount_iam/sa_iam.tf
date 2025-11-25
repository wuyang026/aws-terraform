resource "kubernetes_service_account" "sa" {
  for_each = { for irsa in local.irsa_list : irsa.name => irsa }

  metadata {
    name      = each.value.service_account
    namespace = each.value.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = each.value.iam_role_arn
    }
  }
}