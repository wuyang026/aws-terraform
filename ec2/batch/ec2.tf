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
  vpc_security_group_ids = [aws_security_group.ek2_batch_sg.id]

  associate_public_ip_address = false
  create_eip                  = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies           = var.ec2_iam_role_policies

  enable_volume_tags = false
  root_block_device = {
    encrypted  = var.device_encrypted
    type       = var.device_type
    throughput = 200
    size       = var.device_size
    tags = {
      Name = "${var.instance_name}-gp3"
    }
  }

  # 初期設定
  user_data = templatefile("${path.module}/user_data/user_data.sh", {
    admin_username    = var.admin_user
    default_password  = var.default_password
    normal_users      = var.normal_users
    aws_region        = var.aws_region
    eks_cluster_name  = var.cluster_name
    default_namespace = length(var.eks_namespaces) > 0 ? var.eks_namespaces[0] : ""
  })

  tags = local.common_tags
}