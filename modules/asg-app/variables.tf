variable "subnets" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_profile" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "target_group_arn" {
  type = string
}
