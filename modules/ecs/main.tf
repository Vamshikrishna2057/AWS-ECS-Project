############################################
# ECS CLUSTER
############################################

resource "aws_ecs_cluster" "this" {
  name = "${var.project}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = var.project
  }
}

############################################
# ECS CAPACITY PROVIDERS (Fargate + Spot)
############################################

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}
