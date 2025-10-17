# aws region
aws_region       = "ap-south-1"
environment      = "dev"
cluster_name     = "go-ph2-00-dev-eks-cluster"

# Eks cluster namespaces
eks_namespaces  = ["kube-batch","kube-system"]

# ec2 Variables
instance_name = "go-DACBATS01"
instance_type = "m7i.large"
instance_keypair = "go-ap-south-1"

# vpc
existing_vpc_id  = "vpc-04bdd21020ddba9bc"

# cluster security group
ec2_sg_ingress_rules = [
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["65.0.72.0/24"]},
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["192.178.0.0/24"]}
]

# user setting 
# 各ユーザーが初回ログインする際に、パスワードの変更を求められるように設定する
admin_user = "admin"
normal_users   = ["tis-user","other-user"]
default_password = "P@ssword123"
