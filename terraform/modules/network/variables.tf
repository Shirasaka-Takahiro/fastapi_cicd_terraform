variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "env" {
  description = "Environment name (dev/stg/prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (must match length of azs)"
  type        = list(string)
}

variable "dmz_subnet_cidrs" {
  description = "CIDR blocks for dmz subnets (must match length of azs)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (must match length of azs)"
  type        = list(string)
}
