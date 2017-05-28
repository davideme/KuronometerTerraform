terraform {
  backend "s3" {
    bucket = "kuronometer-terraform-state"
    key    = "global/terraform.tfstate"
    region = "us-east-1"

    lock_table = "terraform-locking"
  }
}
