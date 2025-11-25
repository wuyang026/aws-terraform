data "aws_s3_object" "eks_endpoint" {
  bucket = var.s3_bucket
  key    = var.endpoint_key
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}