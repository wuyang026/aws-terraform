bucket         = "go-s3-bucket-test"
key            = "dev/eks.tfstate"
aws_region     = "ap-south-1"

sa_roles = [
  {
    role_name   = "go-role-efs"
    policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
    sa_name     = "go-efs-server"
    namespace   = "kube-system"
  }
]