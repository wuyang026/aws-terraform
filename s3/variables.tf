variable "s3_buckets" {
  description = "各バケットは名前と保持日数を指定"
  type = list(object({
    name            = string   # バケット名
    retention_days  = number   # オブジェクトの保持日数
  }))
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}