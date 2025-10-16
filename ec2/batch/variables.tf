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