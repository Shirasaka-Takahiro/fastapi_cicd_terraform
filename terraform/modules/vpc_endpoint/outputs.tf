output "ecr_api_endpoint_id" {
  description = "ECR API interface endpoint ID"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ECR DKR interface endpoint ID"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "logs_endpoint_id" {
  description = "CloudWatch Logs interface endpoint ID"
  value       = aws_vpc_endpoint.logs.id
}

output "sts_endpoint_id" {
  description = "STS interface endpoint ID"
  value       = aws_vpc_endpoint.sts.id
}

output "s3_endpoint_id" {
  description = "S3 gateway endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}
