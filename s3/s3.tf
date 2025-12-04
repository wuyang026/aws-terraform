#############################################
# S3 バケット作成
#############################################
resource "aws_s3_bucket" "this" {
  for_each = { for b in var.s3_buckets : b.name => b }
  bucket   = each.value.name

  # destroy 時に削除されない
  lifecycle {
    prevent_destroy = true
  }
}

#############################################
# S3 バージョニング（別リソースで管理）
#############################################
resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

#############################################
# S3 ライフサイクル設定（別リソースで管理）
#############################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for b in var.s3_buckets : b.name => b }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    id     = "retention"
    status = "Enabled"

    expiration {
      days = each.value.retention_days
    }
  }
}

#############################################
# バケット ARN のローカル変数
#############################################
locals {
  bucket_arns = { for k, v in aws_s3_bucket.this : k => v.arn }
}