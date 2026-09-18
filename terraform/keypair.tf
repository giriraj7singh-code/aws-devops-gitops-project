resource "aws_key_pair" "admin" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand("~/.ssh/aws-devops-gitops.pub"))

  tags = {
    Project = var.project_name
  }
}
