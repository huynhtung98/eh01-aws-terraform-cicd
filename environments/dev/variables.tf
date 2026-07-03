variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
  default     = "10.0.0.0/16"
}

variable "ez_websub_cidr" {
  type        = list(string)
  description = "Public subnet CIDRs for the web tier"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "iz_appsub_cidr" {
  type        = list(string)
  description = "Private subnet CIDRs for the app tier"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "iz_dbsub_cidr" {
  type        = list(string)
  description = "Private subnet CIDRs for the DB tier"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zone" {
  type        = list(string)
  description = "Availability zones"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances (Amazon Linux 2023)"
  default     = "ami-049731af5cd9af3ec"
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "db_username" {
  type        = string
  description = "DB master username"
  default     = "admin"
}

# No default on purpose: never commit credentials.
# Pass via TF_VAR_db_password (GitHub secret) or a gitignored terraform.tfvars.
variable "db_password" {
  type        = string
  description = "DB master password"
  sensitive   = true
}
