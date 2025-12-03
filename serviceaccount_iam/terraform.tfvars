bucket         = "go-s3-bucket-test"
key            = "dev/eks.tfstate"
aws_region     = "ap-south-1"

sa_roles = [
  {
    role_name   = "go-role-efs"
    role_arn    = ""
    policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
    sa_name     = "go-efs-server"
    namespace   = "kube-system"
  }
  ,
  {
    role_name   = ""
    role_arn    = "arn:aws:iam::759348358497:role/go-ph2-01-dev-eks-cluster-efs-role-20251203003346273900000006"
    policy_arns = null
    sa_name     = "go-efs-server"
    namespace   = "kube-system"
  }
]