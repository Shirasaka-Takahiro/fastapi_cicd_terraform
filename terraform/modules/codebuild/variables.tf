variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

# ---------------------------------------------------------------------------
# ECR repositories (CodeBuild needs push/pull permissions)
# ---------------------------------------------------------------------------
variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs that CodeBuild needs push/pull permissions on"
  type        = list(string)
}

variable "nginx_ecr_repository_url" {
  type = string
}

variable "python_ecr_repository_url" {
  type = string
}

# ---------------------------------------------------------------------------
# Container roles
# ---------------------------------------------------------------------------
variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

# ---------------------------------------------------------------------------
# Container port
# ---------------------------------------------------------------------------
variable "nginx_container_port" {
  description = "nginx container port"
  type        = number
  default     = 80
}

variable "python_container_port" {
  description = "python container port"
  type        = number
  default     = 8000
}

# ---------------------------------------------------------------------------
# CodeBuild settings
# ---------------------------------------------------------------------------
variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "CodeBuild build image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "buildspec_path" {
  description = "Path of buildspec.yml in the source repository"
  type        = string
}
