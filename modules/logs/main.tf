############################################
# FRONTEND LOG GROUP
############################################
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/frontend"
  retention_in_days = 30
}

############################################
# BACKEND LOG GROUP
############################################
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/backend"
  retention_in_days = 30
}
