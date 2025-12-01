############################################
# Project & Region
############################################
variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

############################################
# IAM Roles (Execution + Task Role)
############################################
variable "execution_role_arn" {
  description = "IAM Execution Role ARN for ECS task"
  type        = string
}

variable "task_role_arn" {
  description = "IAM Task Role ARN"
  type        = string
}

############################################
# ECR Repo
############################################
variable "repo_url" {
  description = "ECR Repository URL"
  type        = string
}

############################################
# Logging
############################################
variable "frontend_log_group" {
  description = "CloudWatch Log Group for Frontend"
  type        = string
}

variable "backend_log_group" {
  description = "CloudWatch Log Group for Backend"
  type        = string
}

############################################
# Database Variables
############################################
variable "db_host" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "db_port" {
  description = "Database port number"
  type        = number
}

variable "db_name" {
  description = "Name of the PostgreSQL DB"
  type        = string
}

############################################
# Secrets Manager ARN
############################################
variable "db_secret_arn" {
  description = "ARN of Secrets Manager DB Credentials Secret"
  type        = string
}
