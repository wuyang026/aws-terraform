# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment Variable"
  type        = string
  default     = "dev"
}

# AWS EC2 Instance Name
variable "instance_name" {
  description = "EC2 Instance Type"
  type = string
  default = "intance_name"  
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t3.micro"  
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "eks-terraform-key"
}

variable "existing_vpc_id" {
  description = "VPC id"
  type        = string
}

# cluster security group
variable "ec2_sg_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "admin_user" {
  description = "admin username"
  type        = string
}

variable "default_password" {
  description = "default password"
  type        = string
}

variable "normal_users" {
  description = "normal usernames"
  type        = list(string)
}

variable "cluster_name" {
  description = "cluster name"
  type        = string
}

variable "eks_access_policy" {
  description = "eks access policy"
  type        = string
}

variable "eks_access_type" {
  description = "eks access type"
  type        = string
}

variable "eks_namespaces" {
  description = "eks namespaces"
  type        = list(string)
}

variable "ec2_iam_role_policies" {
  description = "ec2 iam role policies"
  type        = map(string)
}

variable "device_encrypted" {
  description = "device encrypted"
  type        = bool
  default     = false
}

variable "device_type" {
  description = "device type"
  type        = string
}

variable "device_size" {
  description = "device size"
  type        = number
}