variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create security groups in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block (used for intra-VPC ingress rules)"
  type        = string
}
