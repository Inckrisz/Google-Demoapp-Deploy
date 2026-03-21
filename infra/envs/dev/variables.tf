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

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "aws_profile" {
  type    = string
  default = "thesis"
}