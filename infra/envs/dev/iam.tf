########################################
# ECS TASK EXECUTION ROLE
########################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ecs-execution-role"
    Environment = var.environment
    Project     = var.project
  }
}

# Attach AWS managed policy (IMPORTANT)
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################################
# ECS TASK ROLE (APP ROLE)
########################################

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ecs-task-role"
    Environment = var.environment
    Project     = var.project
  }
}