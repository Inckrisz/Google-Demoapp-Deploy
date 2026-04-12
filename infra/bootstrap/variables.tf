variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "aws_profile" {
  type    = string
  default = "thesis"
}

variable "state_bucket_name" {
  default = "krisztian-aws-thesis-tfstate-eu-north-1"
  type = string
}