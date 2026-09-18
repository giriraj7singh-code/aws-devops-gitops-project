data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "devops" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m7i-flex.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.devops.id]
  key_name                    = aws_key_pair.admin.key_name
  associate_public_ip_address = true

  user_data                   = file("${path.module}/../scripts/bootstrap.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  depends_on = [
    aws_route_table_association.public,
    aws_vpc_security_group_egress_rule.outbound
  ]

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}

output "instance_id" {
  value = aws_instance.devops.id
}

output "server_public_ip" {
  value = aws_instance.devops.public_ip
}
