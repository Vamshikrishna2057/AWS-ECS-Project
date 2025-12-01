############################################ 
# ECR MODULE 
############################################
module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "vamshi-kalakonda-ecs-app"
}

############################################
# VPC MODULE
############################################
module "vpc" {
  source = "../../modules/vpc"

  project = "vamshi-ecs-app"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  azs = ["us-east-1a", "us-east-1b"]
}

############################################
# SECURITY GROUPS MODULE
############################################
module "security_groups" {
  source = "../../modules/security-groups"

  project              = "vamshi-ecs-app"
  vpc_id               = module.vpc.vpc_id
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

############################################
# RDS MODULE
############################################
module "rds" {
  source = "../../modules/rds"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.security_groups.rds_sg_id]

  identifier        = "dev-postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
}

############################################
# SECRETS MANAGER MODULE
############################################
module "db_secrets" {
  source = "../../modules/secrets"

  db_username = var.db_username
  db_password = var.db_password
  db_host     = module.rds.rds_endpoint
  db_name     = var.db_name
  db_port     = 5432
}

############################################
# IAM MODULE
############################################
module "iam" {
  source  = "../../modules/iam"
  project = "vamshi-ecs-app"

  db_secret_arn = module.db_secrets.secret_arn
}

############################################
# LOG GROUPS MODULE
############################################
module "logs" {
  source = "../../modules/logs"
}

############################################
# ECS CLUSTER MODULE
############################################
module "ecs_cluster" {
  source  = "../../modules/ecs"
  project = "vamshi-ecs-app"
}

############################################
# ECS TASK DEFINITIONS MODULE
############################################
module "ecs_tasks" {
  source = "../../modules/ecs-task"

  project = "vamshi-ecs-app"
  region  = var.region

  repo_url = module.ecr.repo_url

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  frontend_log_group = module.logs.frontend
  backend_log_group  = module.logs.backend

  db_host       = module.rds.rds_endpoint
  db_port       = 5432
  db_name       = module.rds.db_name
  db_secret_arn = module.db_secrets.secret_arn
}

############################################
# ALB MODULE
############################################
module "alb" {
  source = "../../modules/alb"

  project        = "vamshi-ecs-app"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_groups.alb_sg_id
}




############################################
# ECS SERVICES MODULE
############################################
module "ecs_services" {
  source = "../../modules/ecs-services"

  project = "vamshi-ecs-app"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  ecs_cluster_id = module.ecs_cluster.cluster_id
  cluster_name   = module.ecs_cluster.cluster_name

  ecs_service_sg_id = module.security_groups.ecs_service_sg_id

  frontend_tg_arn   = module.alb.frontend_tg_arn
  backend_tg_arn    = module.alb.backend_tg_arn
  http_listener_arn = module.alb.http_listener_arn

  frontend_task_def_arn = module.ecs_tasks.frontend_task_def_arn
  backend_task_def_arn  = module.ecs_tasks.backend_task_def_arn
}


module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project       = "vamshi-ecs-app"
  cluster_name  = module.ecs_cluster.cluster_name
  sns_topic_arn = aws_sns_topic.alerts.arn
}



resource "aws_sns_topic" "alerts" {
  name = "vamshi-ecs-app-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "vamshi31cs@gmail.com" # CHANGE THIS
}
