# EKS Cluster Outputs
output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_id" {
  description = "The id of the EKS cluster."
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_cluster_sg_id" {
  value       = aws_security_group.eks_cluster_sg.id
  description = "ID of the EKS cluster security group"
}

output "eks_node_sg_id" {
  value       = aws_security_group.eks_node_sg.id
  description = "ID of the EKS node group security group"
}

output "kms_key_arn" {
  value       = aws_kms_key.eks.arn
  description = "The ARN of the KMS key used by EKS"
}

output "kms_key_rotation_enabled" {
  value       = aws_kms_key.eks.enable_key_rotation
  description = "Whether automatic key rotation is enabled for the KMS key"
}

output "logging_s3_bucket_name" {
  value = data.aws_s3_bucket.existing.bucket
}

output "firehose_stream" {
  value = aws_kinesis_firehose_delivery_stream.cw_to_s3.name
}