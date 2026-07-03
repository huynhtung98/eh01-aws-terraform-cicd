variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "app_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks of the app tier subnets (where the NLB nodes live)"
}
