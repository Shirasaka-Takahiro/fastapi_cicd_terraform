variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

# ---------------------------------------------------------------------------
# Source (GitHub via CodeStar Connections)
# ---------------------------------------------------------------------------
variable "github_owner" {
  description = "GitHub owner/org of the source repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Source branch to track"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "CodeStar Connections ARN for GitHub"
  type        = string
}

# ---------------------------------------------------------------------------
# Build (CodeBuild project, owned by modules/codebuild)
# ---------------------------------------------------------------------------
variable "codebuild_project_name" {
  description = "CodeBuild project name to invoke in the Build stage"
  type        = string
}

variable "codebuild_project_arn" {
  description = "CodeBuild project ARN (used in CodePipeline IAM policy)"
  type        = string
}

# ---------------------------------------------------------------------------
# Deploy (CodeDeploy)
# ---------------------------------------------------------------------------
variable "codedeploy_app_name" {
  description = "CodeDeploy application name"
  type        = string
}

variable "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name"
  type        = string
}
