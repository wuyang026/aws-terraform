# cluster Variables
project_name     = "go-ph2-00"
aws_region       = "ap-south-1"
existing_vpc_id  = "vpc-0af4b08fb5339474e"
cluster_k8s_version = "1.34"
environment      = "dev"

# cluster security group
cluster_sg_ingress_rules = [
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["65.0.72.0/24"]},
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["192.168.0.0/20"]}
]

# node security group tags (security group作成する時にtagを設定)
node_sg_ingress_rules = [
  {description = "",from_port = 0,to_port = 0,protocol = "-1",cidr_blocks = ["192.168.0.0/20"]}
]

# public endpoint access cidrs
endpoint_public_access_cidrs = []

# efs csi driver version
efs_csi_driver_version = "v2.1.13-eksbuild.1"

# node pool Variables
instance_architecture = ["amd64"]
capacity_type = ["spot","on-demand"]
instance_cpu = ["2","4","8","16"]
instance_category = ["c","m","r"]