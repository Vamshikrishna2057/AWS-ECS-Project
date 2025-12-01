############################################
# ALB SECURITY GROUP
############################################
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALB to send outbound traffic to ECS tasks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-alb-sg"
  }
}

############################################
# ECS SERVICE SECURITY GROUP
############################################
resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.project}-ecs-service-sg"
  description = "Security group for ECS frontend & backend tasks"
  vpc_id      = var.vpc_id

  # ALB → Frontend (port 80)
  ingress {
    description      = "Allow ALB to reach frontend on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  # ALB → Backend (port 3000)  <-- FIXED BLOCK
  ingress {
    description      = "Allow ALB to reach backend on port 3000"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  # Outbound for ECS tasks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


############################################
# RDS SECURITY GROUP (FINAL FIX)
############################################
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = var.vpc_id

  # Allow ECS tasks (SG → SG rule)
  ingress {
    description     = "Allow ECS tasks to access PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-sg"
  }
}