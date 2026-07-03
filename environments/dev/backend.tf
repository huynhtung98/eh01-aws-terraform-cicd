terraform {
  backend "s3" {
    bucket         = "s3-eh01-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "eh01-terraform-lock"
    encrypt        = true
  }
}
