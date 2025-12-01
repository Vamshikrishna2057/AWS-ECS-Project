output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "http_listener_arn" {
  value = aws_lb_listener.http_listener.arn
}

