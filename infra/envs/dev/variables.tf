variable "name_prefix" {
  description = "Prefix for the ECS cluster name"
  type        = string
  default = "kriszboutique"
}

variable "environment" {
  description = "Environment tag (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name for tags"
  type = string
  default = "project_thesis"
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "aws_profile" {
  type    = string
  default = "thesis"
}

variable "domain_name" {
  type = string
  default = null
}