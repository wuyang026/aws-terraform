resource "aws_ecr_repository" "repo" {
  for_each = toset(var.ecr_repo_names)

  name = "${each.key}-${var.environment}-ecr"

  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${each.key}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each   = aws_ecr_repository.repo
  repository = each.value.name
  policy     = file("${path.module}/lifecycle/lifecycle_policy.json")
}