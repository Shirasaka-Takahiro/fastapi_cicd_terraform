variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to the DB instance"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master username"
  type        = string
}

variable "db_password" {
  description = "Master password (sensitive)"
  type        = string
  sensitive   = true
}

variable "engine" {
  description = "DB engine"
  type        = string
  default     = "postgres"
}


variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "parameter_group_family" {
  description = "DB parameter group family (must match engine version)"
  type        = string
  default     = "postgres16"
}

variable "instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage (GiB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max storage autoscaling (GiB). 0 to disable."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "apply_immediately" {
  description = "Apply changes immediately rather than during the next maintenance window"
  type        = bool
  default     = false
}
