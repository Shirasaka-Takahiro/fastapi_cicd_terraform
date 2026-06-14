variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to launch ECS tasks in (dmz subnets)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to tasks"
  type        = string
}

variable "blue_target_group_arn" {
  description = "Initial (blue) target group ARN to attach to the service"
  type        = string
}

# ---------------------------------------------------------------------------
# Container: nginx (ALB target)
# ---------------------------------------------------------------------------
variable "nginx_container_image" {
  description = "nginx container image URI (e.g. ECR URL with tag)"
  type        = string
}

variable "nginx_container_port" {
  description = "nginx container port (target group port)"
  type        = number
  default     = 80
}

# ---------------------------------------------------------------------------
# Container: python (FastAPI)
# ---------------------------------------------------------------------------
variable "python_container_image" {
  description = "python container image URI (e.g. ECR URL with tag)"
  type        = string
}

variable "python_container_port" {
  description = "python container port"
  type        = number
  default     = 8000
}

# ---------------------------------------------------------------------------
# Task-level
# ---------------------------------------------------------------------------
variable "cpu" {
  description = "Task-level CPU units"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "Task-level memory (MiB)"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "log_group_name" {
  description = "CloudWatch Logs group name for awslogs driver"
  type        = string
}

variable "deployment_controller" {
  description = "Deployment controller for ECS"
  type        = string
}