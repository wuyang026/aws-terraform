# eks cluster access role
resource "aws_eks_access_entry" "ec2_batch_auto_entry" {
  cluster_name    = var.cluster_name
  principal_arn   = module.ec2_batch.iam_role_arn
}

resource "aws_eks_access_policy_association" "ec2_batch_access" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = module.ec2_batch.iam_role_arn

  access_scope {
    type = "namespace"
    namespaces = var.eks_namespaces
  }

  depends_on = [aws_eks_access_entry.ec2_batch_auto_entry]
}