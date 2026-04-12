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

# variable "public_subnet_cidrs" {
#   description = "CIDR blocks for public subnets"
#   type        = list(string)
# }

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required."
  }
}