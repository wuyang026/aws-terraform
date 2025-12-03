##########################
# 1. KMSキー作成（自動ローテーション有効）
##########################
resource "aws_kms_key" "eks" {
  description         = "EKS Auto Mode 用 KMSキー" 
  # deletion_window_in_days = 7
  enable_key_rotation = true # 自動ローテーション（1年ごと）
}

# KMS エイリアス
resource "aws_kms_alias" "eks" {
  name          = "alias/${local.cluster_name}-kms" # alias/ プレフィックス必須
  target_key_id = aws_kms_key.eks.id
}

##########################
# 2. KMSキー ポリシー設定
##########################
resource "aws_kms_key_policy" "eks_policy" {
  key_id = aws_kms_key.eks.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # 2-1. 管理者権限（AWSアカウント rootユーザー）
      {
        Sid       = "AllowAccountAdmin"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      # 2-2. EKS Cluster が Secrets を暗号化できる権限
      {
        Sid       = "AllowEKSCluster"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

##########################
# 3. NodeGroup IAM Role に KMS権限付与
##########################
resource "aws_iam_role_policy" "node_kms_policy" {
  name = "${local.cluster_name}-kms-policy"

  # 注意: role は ARN ではなく Role 名称を指定
  role = split("/", module.eks.node_iam_role_arn)[1]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.eks.arn
      }
    ]
  })
  depends_on = [module.eks]
}