module "network" {
    source      = "../../modules/network"

    environment = "dev"
    project     = "aws-thesis"
}

module "ecs_cluster" {
  source      = "../../modules/ecs_cluster"
  name_prefix = "kriszboutique"
  environment = "dev"
  project = "aws-thesis"

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

module "alb" {
  source = "../../modules/alb"

  name_prefix     = "kriszboutique"
  subnet_ids      = module.network.public_subnet_ids
  security_groups = [module.alb_sg.security_group_id]
  enable_deletion_protection = false

  environment = "dev"
  project     = "aws-thesis"
}