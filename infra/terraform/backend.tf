terraform {
  backend "s3" {
    bucket         = "lock-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "assignment-lock-table"
    encrypt        = true
  }
}