variable "name_prefix" {
  description = "Prefix for the ECS cluster name"
  type        = string
  default     = "kriszboutique"
}

variable "environment" {
  description = "Environment tag (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name for tags"
  type        = string
  default     = "project_thesis"
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
  type    = string
  default = null
}

variable "adservice_image" {
  type = string
}

variable "cartservice_image" {
  type = string
}

variable "checkoutservice_image" {
  type = string
}

variable "currencyservice_image" {
  type = string
}

variable "emailservice_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "loadgenerator_image" {
  type = string
}

variable "paymentservice_image" {
  type = string
}

variable "productcatalogservice_image" {
  type = string
}

variable "recommendationservice_image" {
  type = string
}

variable "shippingservice_image" {
  type = string
}

variable "shoppingassistantservice_image" {
  type = string
}