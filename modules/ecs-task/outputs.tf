output "frontend_task_def_arn" {
  value = aws_ecs_task_definition.frontend.arn
}

output "backend_task_def_arn" {
  value = aws_ecs_task_definition.backend.arn
}
