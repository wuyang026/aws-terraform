variable "irsa_list" {
  type = list(object({
    name            = string
    namespace       = string
    service_account = string
    iam_role_arn    = string
  }))
}
