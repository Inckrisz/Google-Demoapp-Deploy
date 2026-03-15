variable "vpc_name" {
  description = "Name of the VPC"
  type = string
}
variable "environment" {
  description = "Environment name for tags"
  type = string
}
variable "project" {
  description = "Project name for tags"
  type = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}
