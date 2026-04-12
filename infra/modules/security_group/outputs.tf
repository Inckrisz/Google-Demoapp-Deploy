output "security_group_id" {
  description = "ID of the Security Group"
  value       = aws_security_group.this.id
}

output "security_group_rule" {
  description = "Ingress rule id"
  value       = aws_vpc_security_group_ingress_rule.allow_tls_ipv4.id
}

output "security_group_rule" {
  description = "Egress rule id"
  value       = aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4.id
}