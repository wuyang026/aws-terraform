# aws Variables
aws_region            = "ap-south-1"
environment           = "dev"

# ec2 Variables
instance_name = "go-DACBATS01"
instance_type = "m7i.large"
# system storage
system_device_encrypted  = true
system_device_type       = "gp3"
system_device_size       = 30

# vpc
existing_vpc_id  = "vpc-04bdd21020ddba9bc"

# ec2 security group
ec2_sg_ingress_rules = [
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["65.0.72.0/24"]},
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["192.178.0.0/24"]}
]

# user setting 
# 各ユーザーが初回ログインする際に、パスワードの変更を求められるように設定する
admin_user = "admin"
normal_users   = ["tis-user","other-user"]
default_password = "P@ssword123"

# 「cluster_name = ""」を指定すると、クラスタにアクセスの設定を行わない
cluster_name          = "go-ph2-00-dev-eks-cluster"
ec2_iam_role_policies = {
  eks_cluster_policy      = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  eks_worker_node_policy  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  ecr_readonly_policy     = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# eks cluster access entry
eks_access_policy = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

# access typeは「cluster,namespace」設定可能です
# namespaceを設定すると、eks_namespacesの指定が必要です
eks_access_type = "namespace"

# eks_access_type に "namespace" を指定し、eks_namespaces を設定することで、EC2は指定されたnamespaceのみにアクセスが制限されます
# eks_access_type に "cluster" を指定しつつ、eks_namespaces に kubectl get pod のデフォルトnamespace(1番目)を設定することも可能です
eks_namespaces  = ["kube-system","ph2-batch"]
