############################################
# OUTPUTS FOR RDS MODULE
############################################

output "rds_endpoint" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Database name passed into RDS module"
  value       = var.db_name
}
