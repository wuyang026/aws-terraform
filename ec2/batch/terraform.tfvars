# aws
aws_region            = "ap-south-1"
environment           = "dev"
cluster_name          = "go-ph2-00-dev-eks-cluster"
ec2_iam_role_policies = {
  eks_cluster_policy      = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  eks_worker_node_policy  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  ecr_readonly_policy     = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Eks cluster namespaces
# 1番目の namespace がデフォルトに設定されているため、kubectl get pod 実行時に -n を省略できます
eks_namespaces  = ["kube-system","ph2-batch"]

# ec2 Variables
instance_name = "go-DACBATS01"
instance_type = "m7i.large"
instance_keypair = "go-ap-south-1"
# root_device
device_encrypted  = true
device_type       = "gp3"
device_size       = 50

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
