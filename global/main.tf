module "backend" {
  source          = "./backend"
  bucket_name     = "terraform-state-vamshi-ecs"
  lock_table_name = "vamshi-terraform-locks"
}
