output "project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.this.name
}

output "project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.this.arn
}

output "role_arn" {
  description = "CodeBuild service role ARN"
  value       = aws_iam_role.codebuild.arn
}
