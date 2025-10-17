# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_batch" {
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
  create_eip                  = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies           = ec2_iam_role_policies

  enable_volume_tags = false
  root_block_device = {
    encrypted  = true
    type       = "gp3"
    throughput = 200
    size       = 50
    tags = {
      Name = "${var.instance_name}-gp3"
    }
  }

  # kubect, git, eksctl, awsインストール
  user_data = templatefile("${path.module}/user_data/user_data.sh", {
    admin_username    = var.admin_user
    default_password  = var.default_password
    normal_users      = var.normal_users
    region            = var.aws_region
    cluster_name      = var.cluster_name
    default_namespace = var.eks_namespaces[0]
  })

  tags = local.common_tags
}