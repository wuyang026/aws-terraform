# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}

# Project Name
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ph2"
}

variable "cluster_k8s_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.34"
}

variable "instance_cpu" {
  description = "Instance cpus  used to node pools"
  type        = list(string)
}

variable "instance_category" {
  description = "Instance category  used to node pools"
  type        = list(string)
}

variable "instance_architecture" {
  description = "Instance architecture  used to node pools"
  type        = list(string)
}

variable "capacity_type" {
  description = "Instance apacity type  used to node pools"
  type        = list(string)
}

variable "existing_vpc_id" {
  description = "VPC id"
  type        = string
}

variable "efs_csi_driver_version" {
  description = "EFS CSI Driver Version"
  type        = string
  default     = "v2.1.12-eksbuild.1"
}

variable "endpoint_public_access_cidrs" {
  description = "endpoint public access cidrs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# cluster security group
variable "cluster_sg_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

# node security group
variable "node_sg_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
