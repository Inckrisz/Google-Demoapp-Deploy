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
  name_prefix = var.name_prefix
  environment = var.environment
  project     = var.project
}

module "ecs_task_definition_adservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "adservice-${var.environment}"
  containers = [
    {
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
  ]
}


module "ecs_task_definition_cartservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "cartservice-${var.environment}"
 containers = [
  {
    "name": "cartservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/cartservice@sha256:3b385efb016c741f5d5d94c3f7fc82736097cf70a1372a63fb6d8644b42930bb",
    "cpu": 0,
    "portMappings": [
      {
        "name": "cartservice-7070-tcp",
        "containerPort": 7070,
        "hostPort": 7070,
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
        "name": "DISABLE_TRACING",
        "value": "true"
      },
      {
        "name": "REDIS_ADDR",
        "value": "redis-cart.kriszboutique-dev-internal:6379"
      },
      {
        "name": "REDIS_CONNECTION_STRING",
        "value": "redis-cart.kriszboutique-dev-internal:6379"
      }
    ],
    "environmentFiles": [],
    "mountPoints": [],
    "volumesFrom": [],
    "ulimits": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/cartservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_checkoutservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "checkoutservice-${var.environment}"
  containers = [
  {
    "name": "checkoutservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/checkoutservice@sha256:b59ac1ee837421f3aae8e7e14f16a22fef30f9c5035847c957cfd42329b230a2",
    "cpu": 0,
    "portMappings": [
      {
        "name": "checkoutservice-5050-tcp",
        "containerPort": 5050,
        "hostPort": 5050,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "CART_SERVICE_ADDR",
        "value": "cartservice.kriszboutique-dev-internal:7070"
      },
      {
        "name": "PAYMENT_SERVICE_ADDR",
        "value": "paymentservice.kriszboutique-dev-internal:50051"
      },
      {
        "name": "EMAIL_SERVICE_ADDR",
        "value": "emailservice.kriszboutique-dev-internal:8080"
      },
      {
        "name": "PRODUCT_CATALOG_SERVICE_ADDR",
        "value": "productcatalogservice.kriszboutique-dev-internal:3550"
      },
      {
        "name": "PORT",
        "value": "5050"
      },
      {
        "name": "DISABLE_TRACING",
        "value": "true"
      },
      {
        "name": "DISABLE_PROFILER",
        "value": "true"
      },
      {
        "name": "CURRENCY_SERVICE_ADDR",
        "value": "currencyservice.kriszboutique-dev-internal:7000"
      },
      {
        "name": "SHIPPING_SERVICE_ADDR",
        "value": "shippingservice.kriszboutique-dev-internal:50051"
      }
    ],
    "environmentFiles": [],
    "mountPoints": [],
    "volumesFrom": [],
    "ulimits": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/checkoutservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_currencyservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "currencyservice-${var.environment}"
  containers = [
  {
    "name": "currencyservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/currencyservice@sha256:ac44dbc7d24526b3159467055bdff8d72e8e376e9947f9f3f9567a75d943f025",
    "cpu": 0,
    "portMappings": [
      {
        "name": "currencyservice-7000-tcp",
        "containerPort": 7000,
        "hostPort": 7000,
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
        "value": "7000"
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
        "awslogs-group": "/ecs/currencyservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_emailservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "emailservice-${var.environment}"
  containers = [
  {
    "name": "emailservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/emailservice@sha256:9bd6468012a01b981a1b97fd0a6e522bece5b387c903f95e476aa2646d52fed4",
    "cpu": 0,
    "portMappings": [
      {
        "name": "emailservice-8080-tcp",
        "containerPort": 8080,
        "hostPort": 8080,
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
        "awslogs-group": "/ecs/emailservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_frontend" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "frontend-${var.environment}"
  containers = [
  {
    "name": "frontend",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/frontend@sha256:5ff233bc21260cbeef46648b32ed401d2ef13c1c7e1da733b4c36110e423ba9a",
    "cpu": 0,
    "portMappings": [
      {
        "name": "frontend",
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "RECOMMENDATION_SERVICE_ADDR",
        "value": "recommendationservice.kriszboutique-dev-internal:8080"
      },
      {
        "name": "CART_SERVICE_ADDR",
        "value": "cartservice.kriszboutique-dev-internal:7070"
      },
      {
        "name": "PORT",
        "value": "8080"
      },
      {
        "name": "PRODUCT_CATALOG_SERVICE_ADDR",
        "value": "productcatalogservice.kriszboutique-dev-internal:3550"
      },
      {
        "name": "GOTRACEBACK",
        "value": "single"
      },
      {
        "name": "SHOPPING_ASSISTANT_SERVICE_ADDR",
        "value": "localhost:8080"
      },
      {
        "name": "AD_SERVICE_ADDR",
        "value": "adservice.kriszboutique-dev-internal:9555"
      },
      {
        "name": "CHECKOUT_SERVICE_ADDR",
        "value": "checkoutservice.kriszboutique-dev-internal:5050"
      },
      {
        "name": "CURRENCY_SERVICE_ADDR",
        "value": "currencyservice.kriszboutique-dev-internal:7000"
      },
      {
        "name": "SHIPPING_SERVICE_ADDR",
        "value": "shippingservice.kriszboutique-dev-internal:50051"
      }
    ],
    "environmentFiles": [],
    "mountPoints": [],
    "volumesFrom": [],
    "ulimits": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/frontend",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]

}

module "ecs_task_definition_paymentservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "paymentservice-${var.environment}"
  containers = [
  {
    "name": "paymentservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/paymentservice@sha256:585bb221b8259fec3805679f78c97c44675a604beb4c8e97f29bef5afda6b618",
    "cpu": 0,
    "portMappings": [
      {
        "name": "paymentservice-50051-tcp",
        "containerPort": 50051,
        "hostPort": 50051,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "PORT",
        "value": "50051"
      },
      {
        "name": "DISABLE_PROFILER",
        "value": "true"
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
        "awslogs-group": "/ecs/paymentservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_productcatalogservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "productcatalogservice-${var.environment}"
  containers = [
  {
    "name": "productcatalogservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/productcatalogservice@sha256:bd98e5d45ad0e2a5badeb09445a090ee2c63df4e0d6385ac551f0cb4a6fcd243",
    "cpu": 0,
    "portMappings": [
      {
        "name": "grpc",
        "containerPort": 3550,
        "hostPort": 3550,
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
        "name": "GRPC_HEALTH_PROBE_VERSION",
        "value": "0.4.18"
      },
      {
        "name": "GOTRACEBACK",
        "value": "single"
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
        "awslogs-group": "/ecs/productcatalogservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_recommendationservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "recommendationservice-${var.environment}"
  containers = [
  {
    "name": "recommendationservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/recommendationservice@sha256:92caf4fd9a7b7adbf5df4234f086dc450f9ea1bb8bd83930be6c6b9c31847f67",
    "cpu": 0,
    "portMappings": [
      {
        "name": "recommendationservice-8080-tcp",
        "containerPort": 8080,
        "hostPort": 8080,
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
        "value": "8080"
      },
      {
        "name": "PRODUCT_CATALOG_SERVICE_ADDR",
        "value": "productcatalogservice.kriszboutique-dev-internal:3550"
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
        "awslogs-group": "/ecs/recommendationservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_redis_cart" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "redis_cart-${var.environment}"
  containers = [
  {
    "name": "redis-cart",
    "image": "redis:7-alpine",
    "cpu": 0,
    "portMappings": [
      {
        "name": "redis-cart-6379-tcp",
        "containerPort": 6379,
        "hostPort": 6379,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "REDIS_ADDR",
        "value": "redis-cart.kriszboutique-dev-internal:6379"
      }
    ],
    "environmentFiles": [],
    "mountPoints": [],
    "volumesFrom": [],
    "ulimits": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/redis-cart",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_task_definition_shippingservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  family = "shippingservice-${var.environment}"
  containers = [
  {
    "name": "shippingservice",
    "image": "324037277205.dkr.ecr.eu-north-1.amazonaws.com/shippingservice@sha256:2e65717e5173baed6fd47a84df8370df7a178af0bfe48c2948980719a7d1a20f",
    "cpu": 0,
    "portMappings": [
      {
        "name": "shippingservice-50051-tcp",
        "containerPort": 50051,
        "hostPort": 50051,
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
        "awslogs-group": "/ecs/shippingservice",
        "awslogs-create-group": "true",
        "awslogs-region": "eu-north-1",
        "awslogs-stream-prefix": "ecs"
      },
      "secretOptions": []
    },
    "systemControls": []
  }
]
}

module "ecs_service_adservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.adservice.arn
  enable_load_balancer = false

  container_name = "adservice"
  container_port = 9555
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_adservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_cartservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.cartservice.arn
  enable_load_balancer = false

  container_name = "cartservice"
  container_port = 7070
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_cartservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_checkoutservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.checkoutservice.arn
  enable_load_balancer = false

  container_name = "checkoutservice"
  container_port = 5050
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_checkoutservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_currencyservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.currencyservice.arn
  enable_load_balancer = false

  container_name = "currencyservice"
  container_port = 7000
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_currencyservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_emailservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.emailservice.arn
  enable_load_balancer = false

  container_name = "emailservice"
  container_port = 8080
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_emailservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_frontend" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = null
  enable_load_balancer = true

  container_name = "frontend"
  container_port = 8080
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_frontend.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
  target_group_arn = aws_lb_target_group.frontend.arn
  # iam_role = aws_iam_role.ecs_task_execution_role.arn

  depends_on = [ aws_lb_listener.http ]
}

module "ecs_service_paymentservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.paymentservice.arn
  enable_load_balancer = false

  container_name = "paymentservice"
  container_port = 50051
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_paymentservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_productcatalogservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.productcatalogservice.arn
  enable_load_balancer = false

  container_name = "productcatalogservice"
  container_port = 3550
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_productcatalogservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_recommendationservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.recommendationservice.arn
  enable_load_balancer = false

  container_name = "recommendationservice"
  container_port = 8080
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_recommendationservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
   
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_redis_cart" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.redis_cart.arn
  enable_load_balancer = false
  container_name = "redis_cart"
  container_port = 6379
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_redis_cart.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
   
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_shippingservice" {
  source = "../../modules/ecs_service"
  environment = var.environment
  service_registry_arn = aws_service_discovery_service.shippingservice.arn
  enable_load_balancer = false
  container_name = "shippingservice"
  container_port = 50051
  desired_count = 1
  task_definition_arn = module.ecs_task_definition_shippingservice.task_definition_arn
  security_group_ids = [aws_security_group.ecs_services.id]
  cluster_arn = module.ecs_cluster.cluster_arn
  subnet_ids = module.network.public_subnet_ids
  name_prefix = var.name_prefix
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}