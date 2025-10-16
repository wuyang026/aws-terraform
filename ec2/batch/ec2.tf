# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_complete" {
  # source  = "terraform-aws-modules/ec2-instance/aws" 
  # version = "6.1.2" 
  # sourceローカル化 
  source  = "./modules/ec2"

  name                   = var.instance_name
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  subnet_id              = data.aws_subnets.private_subnets.ids[0]

  create_security_group = false
  vpc_security_group_ids = [aws_security_group.eks_cluster_sg.id]

  associate_public_ip_address = false
  create_eip             = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  enable_volume_tags = false
  root_block_device = {
    encrypted  = true
    type       = "gp3"
    throughput = 200
    size       = 50
    tags = {
      Name = "my-root-block"
    }
  }

  tags = local.common_tags
}