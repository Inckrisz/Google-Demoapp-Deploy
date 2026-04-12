output "ecr_id" {
  description = "ID of the ECR"
  value       = aws_ecr_repository.this.id
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}