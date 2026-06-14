variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "repository_name" {
  description = "ECR repository short name (suffix). Final name is <project>-<env>-<repository_name>."
  type        = string
}

variable "max_image_count" {
  description = "Number of images to keep in the repository (older ones expire)"
  type        = number
  default     = 20
}
