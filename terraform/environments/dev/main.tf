module "network" {
  source = "../../modules/network"

  project              = var.project
  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  dmz_subnet_cidrs     = var.dmz_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_group" {
  source = "../../modules/security_group"

  project  = var.project
  env      = var.env
  vpc_id   = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
}

module "vpc_endpoint" {
  source = "../../modules/vpc_endpoint"

  project            = var.project
  env                = var.env
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.dmz_subnet_ids
  security_group_ids = [module.security_group.vpce_sg_id]
  route_table_ids    = [module.network.dmz_route_table_id]
}

module "cloudwatch_logs" {
  source = "../../modules/cloudwatch_logs"

  project = var.project
  env     = var.env
}

module "ecr_nginx" {
  source = "../../modules/ecr"

  project         = var.project
  env             = var.env
  repository_name = var.nginx_ecr_repository_name
}

module "ecr_python" {
  source = "../../modules/ecr"

  project         = var.project
  env             = var.env
  repository_name = var.python_ecr_repository_name
}

module "acm" {
  source = "../../modules/acm"

  project        = var.project
  env            = var.env
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  env               = var.env
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.security_group.alb_sg_id
  certificate_arn   = module.acm.certificate_arn
  container_port    = var.nginx_container_port
  health_check_path = var.health_check_path
}

module "waf" {
  source = "../../modules/waf"

  project = var.project
  env     = var.env
  alb_arn = module.alb.alb_arn
}

module "route53" {
  source = "../../modules/route53"

  hosted_zone_id = var.hosted_zone_id
  record_name    = var.service_record_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
}

module "rds" {
  source = "../../modules/rds"

  project                = var.project
  env                    = var.env
  subnet_ids             = module.network.private_subnet_ids
  security_group_id      = module.security_group.rds_sg_id
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  parameter_group_family = var.db_parameter_group_family
  instance_class         = var.db_instance_class
}

module "ecs" {
  source = "../../modules/ecs"

  project                = var.project
  env                    = var.env
  subnet_ids             = module.network.dmz_subnet_ids
  security_group_id      = module.security_group.ecs_sg_id
  blue_target_group_arn  = module.alb.blue_target_group_arn
  nginx_container_image  = module.ecr_nginx.repository_url
  nginx_container_port   = var.nginx_container_port
  python_container_image = module.ecr_python.repository_url
  python_container_port  = var.python_container_port
  cpu                    = var.task_cpu
  memory                 = var.task_memory
  desired_count          = var.desired_count
  log_group_name         = module.cloudwatch_logs.log_group_name
  deployment_controller  = var.deployment_controller
}

module "codestar_connection" {
  source = "../../modules/codestar_connection"

  project = var.project
  env     = var.env
}

module "codedeploy" {
  source = "../../modules/codedeploy"

  project                 = var.project
  env                     = var.env
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  blue_target_group_name  = module.alb.blue_target_group_name
  green_target_group_name = module.alb.green_target_group_name
  prod_listener_arn       = module.alb.prod_listener_arn
  test_listener_arn       = module.alb.test_listener_arn
}

module "codebuild" {
  source = "../../modules/codebuild"

  project                   = var.project
  env                       = var.env
  nginx_ecr_repository_url  = module.ecr_nginx.repository_url
  python_ecr_repository_url = module.ecr_python.repository_url
  nginx_container_port      = var.nginx_container_port
  python_container_port     = var.python_container_port
  task_execution_role_arn   = module.ecs.task_execution_role_arn
  task_role_arn             = module.ecs.task_role_arn
  ecr_repository_arns = [
    module.ecr_nginx.repository_arn,
    module.ecr_python.repository_arn,
  ]
  buildspec_path = "terraform/scripts/buildspec.yml"
}

module "codepipeline" {
  source = "../../modules/codepipeline"

  project                          = var.project
  env                              = var.env
  github_owner                     = var.github_owner
  github_repo                      = var.github_repo
  github_branch                    = var.github_branch
  codestar_connection_arn          = module.codestar_connection.connection_arn
  codebuild_project_name           = module.codebuild.project_name
  codebuild_project_arn            = module.codebuild.project_arn
  codedeploy_app_name              = module.codedeploy.app_name
  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name
}
