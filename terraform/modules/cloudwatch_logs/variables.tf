variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "retention_in_days" {
  description = "Log group retention in days"
  type        = number
  default     = 30
}
