resource "aws_ecr_repository" "foo" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  tags = var.all_tags
}