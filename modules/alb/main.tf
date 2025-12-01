############################################
# Application Load Balancer
############################################
resource "aws_lb" "app_lb" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.alb_sg_id]

  enable_deletion_protection = false
}

############################################
# FRONTEND TARGET GROUP
############################################
resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.project}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}

############################################
# BACKEND TARGET GROUP (FINAL WORKING VERSION)
############################################
resource "aws_lb_target_group" "backend_tg" {
  name        = "${var.project}-backend-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/api/hello"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}



############################################
# LISTENER (PORT 80)
############################################
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # DEFAULT → FRONTEND
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

############################################
# ROUTE /api/* → BACKEND (WORKING)
############################################
resource "aws_lb_listener_rule" "backend_api_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
