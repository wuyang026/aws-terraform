resource "aws_ecr_repository" "repo" {
  for_each = toset(var.ecr_repo_names)

  name = "${each.key}-${var.environment}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${each.key}-${var.environment}"
    Environment = var.environment
  }
}