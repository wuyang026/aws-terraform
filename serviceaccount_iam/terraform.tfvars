roles = [
  {
    name        = "role-argo"
    policy_arns = ["arn:aws:iam::111122223333:policy/PolicyA"]
    sa_name     = "argo-server"
    namespace   = "argo"
  },
  {
    name        = "role-prod"
    policy_arns = ["arn:aws:iam::111122223333:policy/PolicyC"]
    sa_name     = "app-sa"
    namespace   = "prod"
  },
  {
    name        = "role-monitoring"
    policy_arns = [
      "arn:aws:iam::111122223333:policy/CloudWatchPolicy",
      "arn:aws:iam::111122223333:policy/EC2ReadOnlyPolicy"
    ]
    sa_name     = "monitoring-sa"
    namespace   = "monitoring"
  }
]
