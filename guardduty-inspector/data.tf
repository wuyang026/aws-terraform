data "aws_caller_identity" "current" {}

# 既存の GuardDuty Detector を取得（存在しなくてもエラーにならない）
data "aws_guardduty_detector" "existing" {}