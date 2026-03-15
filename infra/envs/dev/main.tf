module "network" {
    source      = "../../modules/network"
    
    all_tags = default
}

module "ecs_cluster" {
  source      = "../../modules/ecs_cluster"
  name_prefix = "ecs"
  environment = "dev"

  enable_container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
}