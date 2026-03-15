variable "environment" {
  description = "Environment name for tags"
  type = string
}
variable "project" {
  description = "Project name for tags"
  type = string
}

variable "ip_protocol" {
    description = "IP protocol for egress rule"
    type = string
    default = "-1" # equivalent to all ports
}

variable "security_group_description" {
  description = "Description for security group"
  type = string
}

variable "security_group_name" {
  description = "Name for security group"
  type = string
}

variable "vpc_id" {
  description = "Id of VPC"
  type = string
}

variable "vpc_cidr_block" {
  description = "IPV4 Cidr block of the VPC"
  type = string
}

variable "vpc_cidr_blockipv6" {
  description = "IPV6 Cidr block of the VPC"
  type = string
}

variable "from_port" {
  description = "From port of the security group rule"
    type = number
}

variable "to_port" {
  description = "To port of the security group rule"
  type = number
}

