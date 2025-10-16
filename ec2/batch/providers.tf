provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "null" {}
