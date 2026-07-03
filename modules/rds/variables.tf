variable "subnets" {
  type        = list(string)
  description = "Private DB subnets for the DB subnet group"
}

variable "sg_id" {
  type        = string
  description = "Security group for the DB instance"
}

variable "db_name" {
  type    = string
  default = "labdb"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ standby (costs more; disabled for the lab)"
  default     = false
}
