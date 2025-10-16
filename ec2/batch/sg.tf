resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.ec2_sg_name}"
  vpc_id      = var.existing_vpc_id
  description = "ec2 Security Group"

  dynamic "ingress" {
    for_each = var.ec2_sg_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.ec2_sg_name}"
  }
}