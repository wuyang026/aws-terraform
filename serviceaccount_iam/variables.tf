variable "sa_roles" {
  type = list(object({
    role_name   = optional(string)
    role_arn    = optional(string)
    policy_arns = optional(list(string))
    sa_name     = string
    namespace   = string
  }))
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket" {
  type        = string
}

variable "key" {
  type        = string
}