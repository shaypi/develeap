output "ecr_repository_name" {
  description = "The name of the repository."
  value = [for repo in aws_ecr_repository.repo : repo.name]
}
