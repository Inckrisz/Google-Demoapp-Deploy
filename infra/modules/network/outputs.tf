  output "vpc_id" {
    description = "ID of the VPC"
    value       = aws_vpc.this.id
  }

  output "subnet_ids" {
    description = "Subnet ids"
    value       = aws_subnet.public[*].id
  }

  output "internet_gateway_id" {
    value = aws_internet_gateway.this.id
  }

  output "public_route_table_id" {
    value = aws_route_table.public.id
  }

  output "public_subnet_ids" {
    description = "IDs of the public subnets"
    value       = aws_subnet.public[*].id
  }