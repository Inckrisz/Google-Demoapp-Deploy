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
  type = string
}

variable "security_groups" {
  description = "Security group for Application Load Balancer"
  type = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type = bool
  default = false
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB"
  type        = list(string)
}