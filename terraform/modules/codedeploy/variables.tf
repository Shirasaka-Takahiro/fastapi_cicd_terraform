variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}

variable "blue_target_group_name" {
  description = "Blue target group name"
  type        = string
}

variable "green_target_group_name" {
  description = "Green target group name"
  type        = string
}

variable "prod_listener_arn" {
  description = "Production listener (443) ARN"
  type        = string
}

variable "test_listener_arn" {
  description = "Test listener (8443) ARN"
  type        = string
}

variable "termination_wait_time_in_minutes" {
  description = "Minutes to wait before terminating the old (blue) tasks after a successful deployment"
  type        = number
  default     = 5
}
