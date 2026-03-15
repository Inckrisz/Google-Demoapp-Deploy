data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc_kriszboutique" {
  cidr_block = var.vpc_cidr_block

  tags = var.all_tags
}

resource "aws_subnet" "kriszboutique_subnet-1" {
  vpc_id     = aws_vpc.vpc_kriszboutique.id
  cidr_block = var.subnet_cidr_block_1
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = var.all_tags
}

resource "aws_subnet" "kriszboutique_subnet-2" {
  vpc_id     = aws_vpc.vpc_kriszboutique.id
  cidr_block = var.subnet_cidr_block_2
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = var.all_tags
}

resource "aws_subnet" "kriszboutique_subnet-3" {
  vpc_id     = aws_vpc.vpc_kriszboutique.id
  cidr_block = var.subnet_cidr_block_3
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = var.all_tags
}

resource "aws_internet_gateway" "kriszboutique-igateway" {
  vpc_id = aws_vpc.vpc_kriszboutique.id

  tags =  var.all_tags
}

resource "aws_route_table" "kriszboutique-route_table" {
  vpc_id = aws_vpc.vpc_kriszboutique.id

  route {
    cidr_block = var.internet_cidr_block
    gateway_id = aws_internet_gateway.kriszboutique-igateway.id
  }

  

  route {
    ipv6_cidr_block        = var.internet_cidr_block_ipv6
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = var.all_tags
}

resource "aws_route_table_association" "kriszboutique-rta-1" {
  subnet_id      = aws_subnet.kriszboutique_subnet-1.id
  route_table_id = aws_route_table.kriszboutique-route_table
}

resource "aws_route_table_association" "kriszboutique-rta-2" {
  subnet_id      = aws_subnet.kriszboutique_subnet-2.id
  route_table_id = aws_route_table.kriszboutique-route_table
}

resource "aws_route_table_association" "kriszboutique-rta-3" {
  subnet_id      = aws_subnet.kriszboutique_subnet-3.id
  route_table_id = aws_route_table.kriszboutique-route_table
}

resource "aws_network_acl" "kriszboutique-acl" {
  vpc_id = aws_vpc.vpc_kriszboutique.id
}

resource "aws_network_acl_rule" "kriszboutique-acl-inrule" {
  network_acl_id = aws_network_acl.kriszboutique-acl
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.internet_cidr_block
}


resource "aws_network_acl_rule" "kriszboutique-acl-outrule" {
  network_acl_id = aws_network_acl.kriszboutique-acl
  rule_number    = 100
  egress         = true
  protocol       = -1 
  rule_action    = "allow"
  cidr_block     =  var.internet_cidr_block
}

resource "aws_security_group" "kriszboutique-security_group" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc_kriszboutique.id

  tags = var.all_tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.kriszboutique-security_group
  cidr_ipv4         = var.internet_cidr_block
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 10000
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.kriszboutique-security_group
  cidr_ipv6         = var.internet_cidr_block_ipv6
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 10000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.kriszboutique-security_group
  cidr_ipv4         = var.internet_cidr_block
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.kriszboutique-security_group
  cidr_ipv6         = var.internet_cidr_block_ipv6
  ip_protocol       = "-1" # semantically equivalent to all ports
}