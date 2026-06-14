output "connection_arn" {
  description = "CodeStar Connections connection ARN. Initial activation requires manual approval in the AWS Console."
  value       = aws_codestarconnections_connection.this.arn
}
