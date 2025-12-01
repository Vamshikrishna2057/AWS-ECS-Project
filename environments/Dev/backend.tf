terraform {
  backend "s3" {
    bucket         = "terraform-state-vamshi-ecs"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "vamshi-terraform-locks"
    encrypt        = true
  }
}
