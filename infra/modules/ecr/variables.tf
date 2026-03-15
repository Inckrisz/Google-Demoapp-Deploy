variable "ecr_repository_name" {
  type = string
}

variable "all_tags" {
    type = map()
    default = {
        Name        = "var.ecr_repository_name"
        Environment = "shared"
        Project     = "aws-thesis"
    }
}