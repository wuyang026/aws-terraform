resource "aws_eks_access_entry" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks.node_iam_role_arn
  type          = "EC2"
}

resource "aws_eks_access_policy_association" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = module.eks.node_iam_role_arn
  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.auto_mode]
}

resource "time_sleep" "policy_create" {
  depends_on = [aws_eks_access_policy_association.auto_mode]
  create_duration = "10s"
}

# Node class作成
resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = templatefile("${path.module}/node_file/node-class.yaml", {
    eks_cluster_name     = module.eks.cluster_name
    eks_auto_node_policy = module.eks.node_iam_role_name
    node_class_name      = local.node_class_name
    tag_subnet_value     = var.tag_subnet_value
    tag_node_sg_name_value    = aws_security_group.eks_node_sg.tags["Name"]
  })
  depends_on = [module.eks,time_sleep.policy_create]
}

# Node pool作成
resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = templatefile("${path.module}/node_file/node-pool.yaml", {
    node_class_name       = local.node_class_name
    node_pool_name        = "${local.node_pool_name}"
    instance_cpu          = "${join("\", \"", var.instance_cpu)}"
    instance_category     = "${join("\", \"", var.instance_category)}"
    capacity_type         = "${join("\", \"", var.capacity_type)}"
    instance_architecture = "${join("\", \"", var.instance_architecture)}"
  })
  depends_on = [kubectl_manifest.karpenter_node_class, module.eks]
}