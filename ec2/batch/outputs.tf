output "ecr_repo_urls" {
  value = {
    for repo_name, repo in aws_ecr_repository.repo :
    "${repo_name}-${var.environment}" => repo.repository_url
  }
}
