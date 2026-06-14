output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.this.name
}

output "artifact_bucket_name" {
  description = "Pipeline artifact S3 bucket name"
  value       = aws_s3_bucket.artifact.bucket
}
