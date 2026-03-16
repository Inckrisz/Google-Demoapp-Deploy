resource "aws_ecs_task_definition" "service" {
  family = var.family
  container_definitions = jsonencode(var.containers)
}