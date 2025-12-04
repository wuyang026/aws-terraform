aws_region     = "ap-south-1"

s3_buckets = [
    { name = "go-ph2-01-gate-dev-eks-cluster-bucket ", retention_days = 365 },
    { name = "go-ph2-01-exten-eks-cluster-bucket ", retention_days = 365 }
]