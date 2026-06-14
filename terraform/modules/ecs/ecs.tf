locals {
  name_prefix = "${var.project}-${var.env}"
}

data "aws_region" "current" {}

resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${local.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${local.name_prefix}-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${local.name_prefix}-ecs-task-role"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${local.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = templatefile("${path.module}/task_definition.json", {
    project                = var.project
    env                    = var.env
    nginx_container_image  = var.nginx_container_image
    nginx_container_port   = var.nginx_container_port
    python_container_image = var.python_container_image
    python_container_port  = var.python_container_port
    log_group_name         = var.log_group_name
    region                 = data.aws_region.current.name
  })

  tags = {
    Name = "${local.name_prefix}-task"
  }
}

resource "aws_ecs_service" "this" {
  name             = "${local.name_prefix}-service"
  cluster          = aws_ecs_cluster.this.id
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  deployment_controller {
    type = var.deployment_controller
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.blue_target_group_arn
    container_name   = "${local.name_prefix}-nginx-container"
    container_port   = var.nginx_container_port
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer, desired_count]
  }

  tags = {
    Name = "${local.name_prefix}-service"
  }
}
