data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  tags = {
    "karpenter.sh/discovery" = "${var.tag_subnet_value}"
  }
}
