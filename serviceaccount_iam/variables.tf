variable "roles" {
  type = list(object({
    name        = string
    policy_arns = list(string)
    sa_name     = string
    namespace   = string
  }))
}
