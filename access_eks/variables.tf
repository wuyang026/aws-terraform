variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "principals" {
  description = "List of IAM user/role ARNs to grant access to EKS"
  type = list(object({
    arn            = string
    access_policies = list(string) 
    namespaces = optional(list(string), [])
  }))
}
