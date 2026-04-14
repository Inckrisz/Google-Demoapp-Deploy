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
    "recommendationservice",
    "productcatalogservice",
    "shippingservice",
    "shoppingassistantservice"
  ])
}

module "network" {
  source = "../../modules/network"

  environment = var.environment
  project     = var.project
  vpc_name    = var.name_prefix
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

module "ecs_cluster" {
  source      = "../../modules/ecs_cluster"
  name_prefix = var.name_prefix
  environment = var.environment
  project     = var.project

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

  name_prefix                = var.name_prefix
  subnet_ids                 = module.network.public_subnet_ids
  security_groups            = [aws_security_group.alb.id]
  enable_deletion_protection = false

  environment = var.environment
  project     = var.project
}

module "ecr" {
  source   = "../../modules/ecr"
  for_each = local.ecr_repositories

  ecr_repository_name = "${each.key}-${var.environment}"
  name_prefix         = var.name_prefix
  environment         = var.environment
  project             = var.project
}

module "ecs_task_definition_adservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "adservice-${var.environment}"
  containers = [
    {
      "name" : "adservice",
      "image" : var.adservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "adservice-9555-tcp",
          "containerPort" : 9555,
          "hostPort" : 9555,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "PORT",
          "value" : "9555"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/adservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}


module "ecs_task_definition_cartservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "cartservice-${var.environment}"
  containers = [
    {
      "name" : "cartservice",
      "image" : var.cartservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "cartservice-7070-tcp",
          "containerPort" : 7070,
          "hostPort" : 7070,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        },
        {
          "name" : "REDIS_ADDR",
          "value" : "redis-cart.kriszboutique-dev-internal:6379"
        },
        {
          "name" : "REDIS_CONNECTION_STRING",
          "value" : "redis-cart.kriszboutique-dev-internal:6379"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/cartservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_checkoutservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "checkoutservice-${var.environment}"
  containers = [
    {
      "name" : "checkoutservice",
      "image" : var.checkoutservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "checkoutservice-5050-tcp",
          "containerPort" : 5050,
          "hostPort" : 5050,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "CART_SERVICE_ADDR",
          "value" : "cartservice.kriszboutique-dev-internal:7070"
        },
        {
          "name" : "PAYMENT_SERVICE_ADDR",
          "value" : "paymentservice.kriszboutique-dev-internal:50051"
        },
        {
          "name" : "EMAIL_SERVICE_ADDR",
          "value" : "emailservice.kriszboutique-dev-internal:8080"
        },
        {
          "name" : "PRODUCT_CATALOG_SERVICE_ADDR",
          "value" : "productcatalogservice.kriszboutique-dev-internal:3550"
        },
        {
          "name" : "PORT",
          "value" : "5050"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        },
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "CURRENCY_SERVICE_ADDR",
          "value" : "currencyservice.kriszboutique-dev-internal:7000"
        },
        {
          "name" : "SHIPPING_SERVICE_ADDR",
          "value" : "shippingservice.kriszboutique-dev-internal:50051"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/checkoutservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_currencyservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "currencyservice-${var.environment}"
  containers = [
    {
      "name" : "currencyservice",
      "image" : var.currencyservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "currencyservice-7000-tcp",
          "containerPort" : 7000,
          "hostPort" : 7000,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "PORT",
          "value" : "7000"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/currencyservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_emailservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "emailservice-${var.environment}"
  containers = [
    {
      "name" : "emailservice",
      "image" : var.emailservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "emailservice-8080-tcp",
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/emailservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_frontend" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "frontend-${var.environment}"
  containers = [
    {
      "name" : "frontend",
      "image" : var.frontend_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "frontend",
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "RECOMMENDATION_SERVICE_ADDR",
          "value" : "recommendationservice.kriszboutique-dev-internal:8080"
        },
        {
          "name" : "CART_SERVICE_ADDR",
          "value" : "cartservice.kriszboutique-dev-internal:7070"
        },
        {
          "name" : "PORT",
          "value" : "8080"
        },
        {
          "name" : "PRODUCT_CATALOG_SERVICE_ADDR",
          "value" : "productcatalogservice.kriszboutique-dev-internal:3550"
        },
        {
          "name" : "GOTRACEBACK",
          "value" : "single"
        },
        {
          "name" : "SHOPPING_ASSISTANT_SERVICE_ADDR",
          "value" : "shoppingassistantservice.kriszboutique-dev-internal:8080"
        },
        {
          "name" : "AD_SERVICE_ADDR",
          "value" : "adservice.kriszboutique-dev-internal:9555"
        },
        {
          "name" : "CHECKOUT_SERVICE_ADDR",
          "value" : "checkoutservice.kriszboutique-dev-internal:5050"
        },
        {
          "name" : "CURRENCY_SERVICE_ADDR",
          "value" : "currencyservice.kriszboutique-dev-internal:7000"
        },
        {
          "name" : "SHIPPING_SERVICE_ADDR",
          "value" : "shippingservice.kriszboutique-dev-internal:50051"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/frontend",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]

}

module "ecs_task_definition_loadgenerator" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "loadgenerator-${var.environment}"

  containers = [
    {
      name  = "loadgenerator"
      image = var.loadgenerator_image,
      cpu   = 0

      portMappings = []

      essential = true

      environment = [
        {
          name  = "FRONTEND_ADDR"
          value = "http://frontend.kriszboutique-dev-internal"
        }
      ]

      environmentFiles = []
      mountPoints      = []
      volumesFrom      = []
      ulimits          = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/loadgenerator"
          awslogs-create-group  = "true"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }

      systemControls = []
    }
  ]
}

module "ecs_task_definition_paymentservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "paymentservice-${var.environment}"
  containers = [
    {
      "name" : "paymentservice",
      "image" : var.paymentservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "paymentservice-50051-tcp",
          "containerPort" : 50051,
          "hostPort" : 50051,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "PORT",
          "value" : "50051"
        },
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/paymentservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_productcatalogservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "productcatalogservice-${var.environment}"
  containers = [
    {
      "name" : "productcatalogservice",
      "image" : var.productcatalogservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "grpc",
          "containerPort" : 3550,
          "hostPort" : 3550,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "GRPC_HEALTH_PROBE_VERSION",
          "value" : "0.4.18"
        },
        {
          "name" : "GOTRACEBACK",
          "value" : "single"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/productcatalogservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_recommendationservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "recommendationservice-${var.environment}"
  containers = [
    {
      "name" : "recommendationservice",
      "image" : var.recommendationservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "recommendationservice-8080-tcp",
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "PORT",
          "value" : "8080"
        },
        {
          "name" : "PRODUCT_CATALOG_SERVICE_ADDR",
          "value" : "productcatalogservice.kriszboutique-dev-internal:3550"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/recommendationservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_redis_cart" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "redis_cart-${var.environment}"
  containers = [
    {
      "name" : "redis-cart",
      "image" : "redis:7-alpine",
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "redis-cart-6379-tcp",
          "containerPort" : 6379,
          "hostPort" : 6379,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "REDIS_ADDR",
          "value" : "redis-cart.kriszboutique-dev-internal:6379"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/redis-cart",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_shippingservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "shippingservice-${var.environment}"
  containers = [
    {
      "name" : "shippingservice",
      "image" : var.shippingservice_image,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "shippingservice-50051-tcp",
          "containerPort" : 50051,
          "hostPort" : 50051,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "DISABLE_PROFILER",
          "value" : "true"
        },
        {
          "name" : "DISABLE_TRACING",
          "value" : "true"
        }
      ],
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/shippingservice",
          "awslogs-create-group" : "true",
          "awslogs-region" : "eu-north-1",
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ]
}

module "ecs_task_definition_shoppingassistantservice" {
  source = "../../modules/ecs_task_definition"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  family             = "shoppingassistantservice-${var.environment}"

  containers = [
    {
      name  = "shoppingassistantservice"
      image = var.shoppingassistantservice_image,
      cpu   = 0

      portMappings = [
        {
          name          = "shoppingassistantservice-8080-tcp"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      essential = true

      environment = [
        {
          name  = "DISABLE_PROFILER"
          value = "true"
        },
        {
          name  = "DISABLE_TRACING"
          value = "true"
        }
      ]

      environmentFiles = []
      mountPoints      = []
      volumesFrom      = []
      ulimits          = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/shoppingassistantservice"
          awslogs-create-group  = "true"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }

      systemControls = []
    }
  ]
}

module "ecs_service_adservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.adservice.arn
  enable_load_balancer = false

  container_name      = "adservice"
  container_port      = 9555
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_adservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn
  subnet_ids          = module.network.public_subnet_ids
  name_prefix         = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_cartservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.cartservice.arn
  enable_load_balancer = false

  container_name      = "cartservice"
  container_port      = 7070
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_cartservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_checkoutservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.checkoutservice.arn
  enable_load_balancer = false

  container_name      = "checkoutservice"
  container_port      = 5050
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_checkoutservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_currencyservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.currencyservice.arn
  enable_load_balancer = false

  container_name      = "currencyservice"
  container_port      = 7000
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_currencyservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_emailservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.emailservice.arn
  enable_load_balancer = false

  container_name      = "emailservice"
  container_port      = 8080
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_emailservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_frontend" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.frontend.arn
  enable_load_balancer = true

  container_name      = "frontend"
  container_port      = 8080
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_frontend.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn
  subnet_ids          = module.network.public_subnet_ids
  name_prefix         = var.name_prefix
  target_group_arn    = aws_lb_target_group.frontend.arn
  # iam_role = aws_iam_role.ecs_task_execution_role.arn

  depends_on = [aws_lb_listener.http]
}

module "ecs_service_paymentservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.paymentservice.arn
  enable_load_balancer = false

  container_name      = "paymentservice"
  container_port      = 50051
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_paymentservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_productcatalogservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.productcatalogservice.arn
  enable_load_balancer = false

  container_name      = "productcatalogservice"
  container_port      = 3550
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_productcatalogservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_recommendationservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.recommendationservice.arn
  enable_load_balancer = false

  container_name      = "recommendationservice"
  container_port      = 8080
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_recommendationservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix

  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_redis_cart" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.redis_cart.arn
  enable_load_balancer = false
  container_name       = "redis_cart"
  container_port       = 6379
  desired_count        = 1
  task_definition_arn  = module.ecs_task_definition_redis_cart.task_definition_arn
  security_group_ids   = [aws_security_group.ecs_services.id]
  cluster_arn          = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_shippingservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.shippingservice.arn
  enable_load_balancer = false
  container_name       = "shippingservice"
  container_port       = 50051
  desired_count        = 1
  task_definition_arn  = module.ecs_task_definition_shippingservice.task_definition_arn
  security_group_ids   = [aws_security_group.ecs_services.id]
  cluster_arn          = module.ecs_cluster.cluster_arn
  subnet_ids           = module.network.public_subnet_ids
  name_prefix          = var.name_prefix
  # iam_role = aws_iam_role.ecs_task_execution_role.arn
}

module "ecs_service_shoppingassistantservice" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  service_registry_arn = aws_service_discovery_service.shoppingassistantservice.arn
  enable_load_balancer = false

  container_name      = "shoppingassistantservice"
  container_port      = 8080
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_shoppingassistantservice.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix
}

module "ecs_service_loadgenerator" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  enable_load_balancer = false
  service_registry_arn = null

  container_name      = "loadgenerator"
  container_port      = 8080
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_loadgenerator.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix
}