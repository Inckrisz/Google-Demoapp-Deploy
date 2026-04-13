locals {
  domain_name = coalesce(
    var.domain_name,
    "kriszboutique-${var.environment}-internal"
  )
}

resource "aws_service_discovery_private_dns_namespace" "private" {
  name        = local.domain_name
  description = "Private dns namespace for service discovery"
  vpc         = module.network.vpc_id
}

resource "aws_service_discovery_service" "adservice" {
  name = "adservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# resource "aws_service_discovery_service" "cartservice" {
#   name = "cartservice"

#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.private.id

#     dns_records {
#       ttl  = 15
#       type = "A"
#     }

#     routing_policy = "MULTIVALUE"
#   }

#   health_check_custom_config {
#     failure_threshold = 1
#   }
# }

resource "aws_service_discovery_service" "cartservice" {
  name = "cartservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "checkoutservice" {
  name = "checkoutservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "currencyservice" {
  name = "currencyservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "emailservice" {
  name = "emailservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "redis_cart" {
  name = "redis-cart"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "paymentservice" {
  name = "paymentservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "productcatalogservice" {
  name = "productcatalogservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "recommendationservice" {
  name = "recommendationservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "shippingservice" {
  name = "shippingservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "shoppingassistantservice" {
  name = "shoppingassistantservice"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 15
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

module "ecs_service_loadgenerator" {
  source               = "../../modules/ecs_service"
  environment          = var.environment
  enable_load_balancer = false

  container_name      = "loadgenerator"
  container_port      = 8080
  desired_count       = 1
  task_definition_arn = module.ecs_task_definition_loadgenerator.task_definition_arn
  security_group_ids  = [aws_security_group.ecs_services.id]
  cluster_arn         = module.ecs_cluster.cluster_arn

  subnet_ids  = module.network.public_subnet_ids
  name_prefix = var.name_prefix
}