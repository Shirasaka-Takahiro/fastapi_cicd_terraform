variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listeners"
  type        = string
}

variable "container_port" {
  description = "Container port the target groups forward to"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Target group health check path"
  type        = string
  default     = "/healthcheck.html"
}
