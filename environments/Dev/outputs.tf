output "alb_dns" {
  value = module.alb.alb_dns
}

output "frontend_service" {
  value = module.ecs_services.frontend_service_name
}

output "backend_service" {
  value = module.ecs_services.backend_service_name
}
