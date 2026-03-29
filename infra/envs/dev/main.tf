locals {
  ecr_repositories = toset([
    "adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "loadgenerator",
    "paymentservice",
    "productcatalogservice",
    "shippingservice"
  ])
}

module "network" {
    source      = "../../modules/network"

    environment = var.environment
    project     = var.project
    vpc_name = var.name_prefix
    public_subnet_cidrs = [
      "10.0.1.0/24",
      "10.0.2.0/24"
    ]
}

module "ecs_cluster" {
  source      = "../../modules/ecs_cluster"
  name_prefix = var.name_prefix
  environment = var.environment
  project = var.project

  enable_container_insights = true

  # capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
}

module "alb" {
  source = "../../modules/alb"

  name_prefix     = var.name_prefix
  subnet_ids      = module.network.public_subnet_ids
  security_groups = [aws_security_group.alb.id]
  enable_deletion_protection = false

  environment = var.environment
  project     = var.project
}

module "ecr" {
  source   = "../../modules/ecr"
  for_each = local.ecr_repositories

  ecr_repository_name = "${each.key}-${var.environment}"
}

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "adservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "cartservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "checkoutservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "currencyservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "emailservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "frontend-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "loadgenerator-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "paymentservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "productcatalogservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "cartservice-${var.environment}"
# }

# module "ecr" {
#   source = "../../modules/ecr"

#   ecr_repository_name = "shippingservice-${var.environment}"
# }

module "ecs_task_definition" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "adservice-${var.environment}"
  containers = {
  "name": "adservice",
  "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/adservice@sha256:3fb07a86312fc2d0feab4c9605d380469872979557ee19c37c9e1dd23513c7d1",
  "cpu": 0,
  "portMappings": [
    {
      "name": "adservice-9555-tcp",
      "containerPort": 9555,
      "hostPort": 9555,
      "protocol": "tcp",
      "appProtocol": "http"
    }
  ],
  "essential": true,
  "environment": [
    {
      "name": "DISABLE_PROFILER",
      "value": "true"
    },
    {
      "name": "PORT",
      "value": "9555"
    },
    {
      "name": "DISABLE_TRACING",
      "value": "true"
    }
  ],
  "environmentFiles": [],
  "mountPoints": [],
  "volumesFrom": [],
  "ulimits": [],
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/ecs/adservice",
      "awslogs-create-group": "true",
      "awslogs-region": "eu-north-1",
      "awslogs-stream-prefix": "ecs"
    },
    "secretOptions": []
  },
  "systemControls": []
}
}