variable "vpc_cidr" {
  type = string
}

variable "ez_websub_cidr" {
  type = list(string)
}

variable "iz_appsub_cidr" {
  type = list(string)
}

variable "iz_dbsub_cidr" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}