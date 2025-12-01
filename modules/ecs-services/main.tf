###########################################
# SERVICE DISCOVERY (Backend)
###########################################
resource "aws_service_discovery_private_dns_namespace" "ecs_ns" {
  name        = "${var.project}.local"
  vpc         = var.vpc_id
  description = "Service discovery namespace for ECS"
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs_ns.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

###########################################
# FRONTEND ECS SERVICE
###########################################
resource "aws_ecs_service" "frontend" {
  name            = "${var.project}-frontend-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.frontend_task_def_arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_tg_arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [
    var.http_listener_arn
  ]
}

###########################################
# BACKEND ECS SERVICE
###########################################
resource "aws_ecs_service" "backend" {
  name            = "${var.project}-backend-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.backend_task_def_arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_service_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_tg_arn
    container_name   = "backend"
    container_port   = 3000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }

  depends_on = [
    var.http_listener_arn
  ]
}

###########################################
# AUTOSCALING - FRONTEND
###########################################
resource "aws_appautoscaling_target" "frontend" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_cpu" {
  name               = "${var.project}-frontend-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }
}

###########################################
# AUTOSCALING - BACKEND
###########################################
resource "aws_appautoscaling_target" "backend" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  name               = "${var.project}-backend-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }
}
