# efs_csiバージョン取得
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket         = "go-s3-bucket-test"
    key            = "dev/eks.tfstate"
    region         = "ap-south-1"
  }
}