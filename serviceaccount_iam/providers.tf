provider "kubernetes" {
  host                   = trimspace(data.terraform_remote_state.eks.outputs.cluster_endpoint)
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "aws" {
  region  = var.aws_region
}

provider "null" {}
