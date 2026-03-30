terraform {
    required_version = ">= 1.3.0"

    backend "s3" {
        bucket         = "s3-eh01-terraform-state"
        key            = "prod/terraform.tfstate"
        region         = "ap-southeast-1"
        dynamodb_table = "eh01-terraform-lock"
        encrypt        = true
  }
}