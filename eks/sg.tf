resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.cluster_sg_name}"
  vpc_id      = var.existing_vpc_id
  description = "EKS Cluster Security Group"

  dynamic "ingress" {
    for_each = var.cluster_sg_ingress_rules
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
    Name = "${local.cluster_sg_name}"
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "${local.node_sg_name}"
  description = "EKS Node Security Group"
  vpc_id      = var.existing_vpc_id

  dynamic "ingress" {
    for_each = var.node_sg_ingress_rules
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
    Name = "${local.node_sg_name}"
  }
}