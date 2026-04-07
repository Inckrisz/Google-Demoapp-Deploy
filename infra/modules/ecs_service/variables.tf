variable "name_prefix" {
  description = "Prefix for the ECS service name"
  type        = string
}

variable "environment" {
  type = string
  description = "Environment for the ECS service"
}

variable "desired_count" {
    description = "Desired count of ECS Service"
    type = number
}

# variable "iam_role" {
#   description = "Iam Role of the service"
#   type = string
# }

variable "container_name" {
  description = "Name of the container to associate with the load balancer."
  type = string
}

variable "container_port" {
 description = "Port on the container to associate with the load balancer."
 type = number
}

variable "cluster_arn" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
  default = null
}

variable "listener_dependency" {
  type    = any
  default = null
}

variable "enable_load_balancer" {
  type = bool
  description = "Enable load balancer for ECS service"
}

variable "service_registry_arn" {
  
}