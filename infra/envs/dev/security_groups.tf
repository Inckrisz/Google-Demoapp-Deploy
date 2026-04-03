resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg-${var.environment}"
  description = "Security group for ALB"
  vpc_id      = module.network.vpc_id

  tags = {
    Name        = "${var.name_prefix}-alb-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# resource "aws_vpc_security_group_ingress_rule" "alb_https" {
#   security_group_id = aws_security_group.alb.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   to_port           = 443
#   ip_protocol       = "tcp"
# }

resource "aws_security_group" "ecs_services" {
  name        = "${var.name_prefix}-ecs-sg-${var.environment}"
  description = "Security group for ECS services"
  vpc_id      = module.network.vpc_id

  tags = {
    Name        = "${var.name_prefix}-ecs-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb_frontend" {
  security_group_id            = aws_security_group.ecs_services.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_self_all_tcp" {
  security_group_id            = aws_security_group.ecs_services.id
  referenced_security_group_id = aws_security_group.ecs_services.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_services.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}