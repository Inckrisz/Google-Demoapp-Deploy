output "task_def_id" {
  description = "Id of Task Definition"
  value = aws_ecs_task_definition.service.id
}