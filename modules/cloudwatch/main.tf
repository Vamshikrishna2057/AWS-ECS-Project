###############################################
# CPU ALARM - Frontend
###############################################
resource "aws_cloudwatch_metric_alarm" "frontend_cpu_high" {
  alarm_name          = "${var.project}-frontend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "${var.project}-frontend-service"
  }
}

###############################################
# MEMORY ALARM - Frontend
###############################################
resource "aws_cloudwatch_metric_alarm" "frontend_mem_high" {
  alarm_name          = "${var.project}-frontend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "${var.project}-frontend-service"
  }
}

###############################################
# CPU ALARM - Backend
###############################################
resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "${var.project}-backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "${var.project}-backend-service"
  }
}

###############################################
# MEMORY ALARM - Backend
###############################################
resource "aws_cloudwatch_metric_alarm" "backend_mem_high" {
  alarm_name          = "${var.project}-backend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "${var.project}-backend-service"
  }
}
