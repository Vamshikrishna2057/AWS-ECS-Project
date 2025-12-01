variable "project" {}

variable "vpc_id" {}

variable "ecs_cluster_id" {}

variable "cluster_name" {
  type = string
}

variable "ecs_service_sg_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "frontend_tg_arn" {}
variable "backend_tg_arn" {}
variable "http_listener_arn" {}

variable "frontend_task_def_arn" {}
variable "backend_task_def_arn" {}
