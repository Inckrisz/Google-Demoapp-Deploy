output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_service.this.id
}