resource "random_string" "suffix" {
  length  = 5
  special = false
}


resource "aws_secretsmanager_secret" "db_credentials" {
  name = "dev/postgres/credentials-${random_string.suffix.result}"
}

resource "aws_secretsmanager_secret_version" "db_credentials_value" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}
