output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "service_fqdn" {
  value = module.route53.record_fqdn
}

output "nginx_ecr_repository_url" {
  value = module.ecr_nginx.repository_url
}

output "python_ecr_repository_url" {
  value = module.ecr_python.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_task_execution_role_arn" {
  description = "Use this in taskdef.json executionRoleArn"
  value       = module.ecs.task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "Use this in taskdef.json taskRoleArn"
  value       = module.ecs.task_role_arn
}

output "ecs_log_group_name" {
  value = module.cloudwatch_logs.log_group_name
}

output "codestar_connection_arn" {
  description = "Connection ARN. Initial activation requires manual approval in the AWS Console."
  value       = module.codestar_connection.connection_arn
}

output "codebuild_project_name" {
  value = module.codebuild.project_name
}

output "codepipeline_name" {
  value = module.codepipeline.pipeline_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
