# ----------------------------------------------------------------------------
# Common
# ----------------------------------------------------------------------------
variable "project" {
  description = "Project name used in naming convention <PROJECT>-<ENV>-<RESOURCE>"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

# ----------------------------------------------------------------------------
# Network
# ----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "dmz_subnet_cidrs" {
  description = "DMZ subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

# ----------------------------------------------------------------------------
# DNS / TLS
# ----------------------------------------------------------------------------
variable "domain_name" {
  description = "Primary domain for ACM certificate"
  type        = string
}

variable "hosted_zone_id" {
  description = "Existing Route53 hosted zone ID"
  type        = string
}

variable "service_record_name" {
  description = "FQDN for the service ALIAS record (e.g. app.example.com)"
  type        = string
}

# ----------------------------------------------------------------------------
# ALB
# ----------------------------------------------------------------------------
variable "health_check_path" {
  description = "Healthcheck path for ALB"
  type        = string
  default     = "/"
}


# ----------------------------------------------------------------------------
# ECR repositories (nginx / python)
# ----------------------------------------------------------------------------
variable "nginx_ecr_repository_name" {
  description = "ECR repository short name for nginx (suffix). Final: <project>-<env>-<suffix>"
  type        = string
  default     = "nginx-repository"
}

variable "python_ecr_repository_name" {
  description = "ECR repository short name for python (suffix). Final: <project>-<env>-<suffix>"
  type        = string
  default     = "python-repository"
}

# ----------------------------------------------------------------------------
# ECS: nginx container (ALB target)
# ----------------------------------------------------------------------------
variable "nginx_container_port" {
  description = "nginx container port (ALB forwards traffic here)"
  type        = number
  default     = 80
}

# ----------------------------------------------------------------------------
# ECS: python (FastAPI) container
# ----------------------------------------------------------------------------
variable "python_container_port" {
  description = "python container port"
  type        = number
  default     = 8000
}

# ----------------------------------------------------------------------------
# ECS: service-level
# ----------------------------------------------------------------------------
variable "launch_type" {
  description = "Launch type for ECS"
  type        = string
  default     = "FARGATE"
}

variable "platform_version" {
  description = "Platform version for ECS"
  type        = string
  default     = "1.4.0"
}

# ----------------------------------------------------------------------------
# ECS: task-level
# ----------------------------------------------------------------------------
variable "task_cpu" {
  description = "Task CPU units"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Task memory (MiB)"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired ECS task count"
  type        = number
  default     = 1
}

variable "deployment_controller" {
  description = "Deployment controller for ECS"
  type        = string
  default     = "CODE_DEPLOY"
  #default = "ECS" ##If necesarry
}

# ----------------------------------------------------------------------------
# RDS
# ----------------------------------------------------------------------------
variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master DB username"
  type        = string
}

variable "db_password" {
  description = "Master DB password (use TF_VAR_db_password)"
  type        = string
  sensitive   = true
}

variable "db_engine" {
  description = "DB engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "db_parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = "postgres16"
}

variable "db_instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t4g.micro"
}

# ----------------------------------------------------------------------------
# CI/CD
# ----------------------------------------------------------------------------
variable "github_owner" {
  description = "GitHub owner/org for the source repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to track for CodePipeline source"
  type        = string
  default     = "main"
}

variable "buildspec_path" {
  description = "Buildspec path"
  type        = string
  default     = "terraform/scripts/buildspec.yml"
}