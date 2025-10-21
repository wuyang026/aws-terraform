terraform {
  backend "s3" {
    bucket         = "go-s3-bucket-test"
    key            = "dev/eks.tfstate"
    region         = "ap-south-1"
  }
}