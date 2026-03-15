variable "vpc_name" {
  type = string
  default = "vpc-kriszboutique"
}

variable "vpc_subnet_name" {
    type = string
    default = "kriszboutique-subnet"
}

variable "vpc_routetable_name" {
    type = string
    default = "kriszboutique-routetable"
}

variable "vpc_internetgateway_name" {
    type = string
    default = "kriszboutique-internetgateway"
}

variable "vpc_security_group_name" {
    type = string
    default = "kriszboutique-security_group"
}

variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "all_tags" {
    type = map()
    default = {
        Name        = var.vpc_name
        Environment = "dev"
        Project     = "aws-thesis"
    }
}

variable "subnet_cidr_block_1" {
    type = string
    default = "10.0.0.0/20"
}

variable "subnet_cidr_block_2" {
    type = string
    default = "10.0.16.0/20"
}

variable "subnet_cidr_block_3" {
    type = string
    default = "10.0.32.0/20"
}

variable "internet_cidr_block" {
    type = string
    default = "0.0.0.0/0"
}

variable "internet_cidr_block_ipv6" {
    type = string
    default = "::/0"
}