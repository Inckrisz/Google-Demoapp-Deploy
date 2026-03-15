output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.ID
}

output "subnet_ids" {
  description = "Subnet ids"
  value       = aws_subnet.public[*].id
}