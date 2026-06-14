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
  description = "Subnet IDs for Interface endpoints (typically dmz subnets)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for Interface endpoints"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route table IDs to associate with the S3 Gateway endpoint"
  type        = list(string)
}
