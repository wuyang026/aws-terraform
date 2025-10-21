# eks cluster access role
resource "aws_eks_access_entry" "ec2_batch_auto_entry" {
  count  = var.cluster_name != "" ? 1 : 0
  cluster_name    = var.cluster_name
  principal_arn   = module.ec2_batch.iam_role_arn
}

resource "aws_eks_access_policy_association" "ec2_batch_access" {
  count  = var.cluster_name != "" ? 1 : 0
  cluster_name  = var.cluster_name
  policy_arn    = var.eks_access_policy
  principal_arn = module.ec2_batch.iam_role_arn

  access_scope {
    type = var.eks_access_type
    namespaces = var.eks_access_type == "namespace" ? var.eks_namespaces : null
  }

  depends_on = [aws_eks_access_entry.ec2_batch_auto_entry]
}

# eks cluster access role
#resource "aws_eks_access_entry" "ec2_batch_auto_entry" {
#  count  = data.terraform_remote_state.eks.outputs.cluster_name != "" ? 1 : 0
#  cluster_name    = data.terraform_remote_state.eks.outputs.cluster_name
#  principal_arn   = module.ec2_batch.iam_role_arn
#}

#resource "aws_eks_access_policy_association" "ec2_batch_access" {
#  count  = data.terraform_remote_state.eks.outputs.cluster_name != "" ? 1 : 0
#  cluster_name  = data.terraform_remote_state.eks.outputs.cluster_name
#  policy_arn    = var.eks_access_policy
#  principal_arn = module.ec2_batch.iam_role_arn

#  access_scope {
#    type = var.eks_access_type
#    namespaces = var.eks_access_type == "namespace" ? var.eks_namespaces : null
#  }

#  depends_on = [aws_eks_access_entry.ec2_batch_auto_entry]
#}