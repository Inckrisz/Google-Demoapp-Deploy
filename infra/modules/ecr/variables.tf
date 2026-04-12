variable "ecr_repository_name" {
  type = string
}

variable "name_prefix" {
  description = "Prefix for the ECR Repository name"
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