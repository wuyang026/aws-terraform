data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "go-s3-bucket-test"
    key    = "dev/eks.tfstate"
    region = var.aws_region
  }
}

data "aws_subnets" "public-subnets" {
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}