variable "name_prefix" {
  description = "Prefix for the ECS cluster name"
  type        = string
}

variable "desired_count" {
    description = "Desired count of ECS Service"
    type = number
}

variable "iam_role" {
  description = "Iam Role of the service"
  type = string
}

variable "container_name" {
  description = "Name of the container to associate with the load balancer."
  type = string
}

variable "container_port" {
 description = "Port on the container to associate with the load balancer."
 type = number
}