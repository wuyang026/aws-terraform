################################
# 1. AWS Config 用 S3 バケット
################################
resource "aws_s3_bucket" "config" {
  bucket = "aws-config-${data.aws_caller_identity.current.account_id}-${var.aws_region}-bucket"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Enabled"
  }
}

################################
# 2. AWS Config 用 S3 バケットポリシー
################################
resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

################################
# 3. AWS Config 用 IAM ロール
################################
resource "aws_iam_role" "config_role" {
  name = "AWS-Config-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

################################
# 4. AWS Config Configuration Recorder
################################
resource "aws_config_configuration_recorder" "this" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

################################
# 5. AWS Config Delivery Channel
################################
resource "aws_config_delivery_channel" "this" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config.bucket

  depends_on = [
    aws_s3_bucket_policy.config,
    aws_config_configuration_recorder.this
  ]
}

################################
# 6. AWS Config Recorder 有効化
################################
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.this
  ]
}

################################
# 7. Security Hub（Security Hub CSPM）有効化
################################
resource "aws_securityhub_account" "this" {
  enable_default_standards = false
  auto_enable_controls     = true

  depends_on = [
    aws_config_configuration_recorder_status.this
  ]
}

# CIS AWS Foundations Benchmark v5.0.0 を有効化する
resource "aws_securityhub_standards_subscription" "cis_v5" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/5.0.0"

  timeouts {
    create = "20m"
    delete = "20m"
  }

  depends_on = [
    aws_securityhub_account.this
  ]
}

# AWS Foundational Security Best Practices v1.0.0 を有効化
resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  timeouts {
    create = "10m"
    delete = "10m"
  }

  depends_on = [
    aws_securityhub_account.this
  ]
}

# PCI DSS v4.0.1（クレジットカード情報を扱う場合のみ）
resource "aws_securityhub_standards_subscription" "pci_dss" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/pci-dss/v/4.0.1"

  timeouts {
    create = "15m"
    delete = "15m"
  }

  depends_on = [
    aws_securityhub_account.this
  ]
}