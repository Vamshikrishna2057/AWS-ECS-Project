############################################
# OUTPUTS FOR LOG GROUPS MODULE
############################################

output "frontend" {
  description = "Frontend CloudWatch log group name"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "backend" {
  description = "Backend CloudWatch log group name"
  value       = aws_cloudwatch_log_group.backend.name
}
