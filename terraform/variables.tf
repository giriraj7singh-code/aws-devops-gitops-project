variable "project_name" {
  description = "Name used to identify this project's AWS resources"
  type        = string
  default     = "aws-devops-gitops"
}
variable "admin_cidr" {
  description = "Administrator public IPv4 address with /32"
  type        = string
}
