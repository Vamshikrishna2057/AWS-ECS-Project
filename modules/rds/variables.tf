variable "db_name" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "identifier" {
  default = "postgres-db"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "allocated_storage" {
  default = 20
}

variable "engine_version" {
  default = "15.3"
}

variable "multi_az" {
  default = false
}
