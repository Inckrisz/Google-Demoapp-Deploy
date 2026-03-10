resource "aws_vpc" "vpc_kriszboutique" {
  cidr_block = "10.0.0.0/24"


  tags = {
    Name        = var.vpc_name
    Environment = "shared"
    Project     = "aws-thesis"
  }
}