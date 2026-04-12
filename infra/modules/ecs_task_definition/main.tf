resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  container_definitions    = jsonencode(var.containers)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
}