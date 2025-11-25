data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket         = var.bucket
    key            = var.key
    region         = var.aws_region
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}