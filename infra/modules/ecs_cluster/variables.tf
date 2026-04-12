variable "name_prefix" {
  description = "Prefix for the ECS cluster name"
  type        = string
}

variable "environment" {
  description = "Environment tag (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name for tags"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "List of capacity providers to associate with the ECS cluster"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "default_capacity_provider_strategy" {
  description = "Default strategy for placing tasks across capacity providers"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))

  default = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 0
    }
  ]
}