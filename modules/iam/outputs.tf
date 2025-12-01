############################################
# OUTPUTS FOR IAM MODULE
############################################

output "execution_role_arn" {
  description = "IAM role ARN used by ECS tasks for pulling images & logs"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "IAM role ARN used by ECS backend containers"
  value       = aws_iam_role.ecs_task_role.arn
}
