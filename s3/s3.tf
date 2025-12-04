#############################################
# 複数 S3 バケットの作成
#############################################
resource "aws_s3_bucket" "this" {
  for_each = { for b in var.s3_buckets : b.name => b }
  bucket   = each.value.name

  # destroy 時に削除されない
  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }
}

#############################################
# S3 バケットのライフサイクル設定
#############################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    id     = "retention"
    status = "Enabled"

    expiration {
      days = each.value.retention_days
    }
  }
}

#############################################
# ローカル変数にバケット ARN を格納
#############################################
locals {
  bucket_arns = { for k, v in aws_s3_bucket.this : k => v.arn }
}