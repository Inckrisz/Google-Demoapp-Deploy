output "ecr_id" {
  description = "ID of the ECR"
  value       = aws_ecr_repository.foo.id
}