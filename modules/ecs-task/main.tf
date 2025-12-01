############################################
# Fetch latest ECR images by tag
############################################
data "aws_ecr_image" "frontend" {
  repository_name = "vamshi-kalakonda-ecs-app"
  image_tag       = "frontend-latest"
}

data "aws_ecr_image" "backend" {
  repository_name = "vamshi-kalakonda-ecs-app"
  image_tag       = "backend-latest"
}

############################################
# FRONTEND TASK DEFINITION
############################################
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.repo_url}:frontend-latest@${data.aws_ecr_image.frontend.image_digest}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-group         = var.frontend_log_group
          awslogs-region        = var.region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
}

############################################
# BACKEND TASK DEFINITION (UPDATED)
############################################
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.repo_url}:backend-latest@${data.aws_ecr_image.backend.image_digest}"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      ###############################################
      # ✅ Inject DB Configuration as ENV variables
      ###############################################
      environment = [
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]

      ###############################################
      # 🔥 Secure Credentials from Secrets Manager
      ###############################################
      secrets = [
        {
          name      = "DB_CREDENTIALS"
          valueFrom = var.db_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-group         = var.backend_log_group
          awslogs-region        = var.region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])
}
