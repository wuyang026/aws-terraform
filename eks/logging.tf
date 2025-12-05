#############################################
# ローカル変数にバケット名とARNを設定（既存 S3 を使用）
#############################################
data "aws_s3_bucket" "existing" {
  bucket = var.logging_s3_bucket_name
}

locals {
  bucket_arn = data.aws_s3_bucket.existing.arn
}

#############################################
# Firehose 用 IAM ロール
#############################################
resource "aws_iam_role" "firehose_role" {
  name = "${local.cluster_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]
}

#############################################
# Firehose → S3 用 IAM ポリシー
#############################################
resource "aws_iam_role_policy" "firehose_policy" {
  role = aws_iam_role.firehose_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucket"
        ]
        Resource = [
          local.bucket_arn,
          "${local.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = ["logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

#############################################
# CloudWatch Logs → Firehose 用 IAM ロール
#############################################
resource "aws_iam_role" "cwlogs_to_firehose_role" {
  name = "${local.cluster_name}-cwlogs-to-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {  Service = "logs.${var.aws_region}.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]
}

#############################################
# CloudWatch Logs → Firehose 用 IAM ポリシー
#############################################
resource "aws_iam_role_policy" "cwlogs_to_firehose_policy" {
  role = aws_iam_role.cwlogs_to_firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["firehose:PutRecord", "firehose:PutRecordBatch"],
        Resource = aws_kinesis_firehose_delivery_stream.cw_to_s3.arn
      }
    ]
  })
}

#############################################
# CloudWatch Logs リソースポリシー作成
#############################################
resource "null_resource" "cwlogs_resource_policy" {
  provisioner "local-exec" {
    command = <<EOF
aws logs put-resource-policy \
  --policy-name "CWLogsToFirehose-${local.cluster_name}" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "Service": "logs.${var.aws_region}.amazonaws.com" },
        "Action": "firehose:PutRecord",
        "Resource": "${aws_kinesis_firehose_delivery_stream.cw_to_s3.arn}"
      }
    ]
  }'
EOF
  }
  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]
}

#############################################
# Kinesis Firehose（CloudWatch → S3 配信）
#############################################
resource "aws_kinesis_firehose_delivery_stream" "cw_to_s3" {
  name        = "${local.cluster_name}-cw-log-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = local.bucket_arn
    prefix             = "cloudwatch-logs/"
    buffering_interval = 60
    compression_format = "GZIP"
  }
}

resource "time_sleep" "waiting_log_group_create" {
  depends_on = [aws_eks_addon.cloudwatch_observability]
  create_duration = "120s"
  
  lifecycle {
    ignore_changes = all
  }
}

#############################################
# ログ保持期間を設定
#############################################
resource "null_resource" "update_retention" {
  for_each = { for lg in local.log_groups : lg.name => lg }

  triggers = {
    retention = tostring(each.value.retention)
  }

  provisioner "local-exec" {
    command = <<EOF
aws logs put-retention-policy \
  --log-group-name "${each.value.name}" \
  --retention-in-days ${each.value.retention}
EOF
  }

  depends_on = [
    time_sleep.waiting_log_group_create
  ]
}

#############################################
# CloudWatch Logs → Firehose → S3 サブスクリプションフィルター
#############################################
resource "aws_cloudwatch_log_subscription_filter" "eks_to_s3" {
  for_each = { for lg in local.log_groups : lg.name => lg }

  name            = "${basename(each.value.name)}-to-firehose"
  log_group_name  = each.value.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.cw_to_s3.arn
  role_arn        = aws_iam_role.cwlogs_to_firehose_role.arn

  depends_on = [
    time_sleep.waiting_log_group_create
  ]
}