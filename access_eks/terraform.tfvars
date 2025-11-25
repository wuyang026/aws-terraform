aws_region       = "ap-south-1"
cluster_name     = "go-ph2-01-dev-eks-cluster"

# ユーザ&各サーバARNにEKS操作権限付与
# principals = [
#  {
#    arn             = ユーザ&サーバ(EC2など)ARN
#    access_policies = [EKS操作権限]
#    namespaces      = [] デフォルト操作対象はcluster全体、namespacesを指定する場合、namespaceのみ操作
#  }
# ]
# ※全体の権限の削除について、terraform destroyで実施する
# ※個別の権限の削除について、以下の設定値を削除またはコメントアウトして、terraform applyを実施する
principals = [
  {
    arn             = "arn:aws:iam::759348358497:user/eks-user"
    access_policies = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"]
    namespaces      = ["amazon-cloudwatch"]
  },
  {
    arn             = "arn:aws:iam::759348358497:user/eiji_kanazawa"
    access_policies = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"]
    namespaces      = []
  }
]
