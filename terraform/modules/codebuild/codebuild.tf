locals {
  name_prefix = "${var.project}-${var.env}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "codebuild" {
  name = "${local.name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${local.name_prefix}-codebuild-role"
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${local.name_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        # Scoped to the pipeline artifact bucket created by the codepipeline module
        # (same naming convention: <project>-<env>-pipeline-artifact-<account-id>).
        Resource = [
          "arn:aws:s3:::${local.name_prefix}-pipeline-artifact-*",
          "arn:aws:s3:::${local.name_prefix}-pipeline-artifact-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]
        Resource = var.ecr_repository_arns
      }
    ]
  })
}

resource "aws_codebuild_project" "this" {
  name         = "${local.name_prefix}-build"
  description  = "Build project for ${local.name_prefix}"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "PROJECT"
      value = var.project
    }

    environment_variable {
      name  = "ENV"
      value = var.env
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "REGION"
      value = "ap-northeast-1"
    }

    environment_variable {
      name  = "NGINX_REPOSITORY_URL"
      value = var.nginx_ecr_repository_url
    }

    environment_variable {
      name  = "PYTHON_REPOSITORY_URL"
      value = var.python_ecr_repository_url
    }

    environment_variable {
      name  = "NGINX_CONTAINER_PORT"
      value = var.nginx_container_port
    }

    environment_variable {
      name  = "PYTHON_CONTAINER_PORT"
      value = var.python_container_port
    }

    environment_variable {
      name  = "EXECUTION_ROLE_ARN"
      value = var.task_execution_role_arn
    }

    environment_variable {
      name  = "TASK_ROLE_ARN"
      value = var.task_role_arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }

  tags = {
    Name = "${local.name_prefix}-build"
  }
}
