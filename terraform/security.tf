resource "aws_security_group" "devops" {
  name        = "${var.project_name}-sg"
  description = "Security group for the DevOps lab"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.devops.id
  description       = "SSH from administrator public IP only"

  cidr_ipv4   = var.admin_cidr
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.devops.id
  description       = "Allow outbound IPv4 traffic for lab setup"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.devops.id
  description       = "Public HTTP access through Nginx"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
