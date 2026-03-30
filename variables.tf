#add tiitle, var for ami, instace type, username and password for db
#Default VPC CIDR Range
variable "vpc_cidr" {
  type = string
  description = "VPC CIDR Range"
  default = "10.0.0.0/16"
}

variable "vpc_cidr_mgmt" {
  type = string
  description = "VPC CIDR Range for Management Zone"
  default = "10.0.0.0/16"
}


#Default Private Subnet CIDR for Management Zone
variable "iz_mgmtsub_cidr" {
  type = string
  description = "Private Subnet CIDR for Management Zone"
  default = "10.0.1.0/24"
}

#Default Public Subnet CIDR for Web tier
variable "ez_websub_cidr" {
  type = list(string)
  description = "Public Subnet CIDR for Web tier"
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

#Default Private Subnet CIDR for App tier
variable "iz_appsub_cidr" {
  type = list(string)
  description = "Private Subnet CIDR for App tier"
  default = [ "10.0.3.0/24", "10.0.4.0/24" ]
}

#Default Private Subnet CIDR for DB tier
variable "iz_dbsub_cidr" {
  type = list(string)
  description = "Private Subnet CIDR for DB tier"
  default = [ "10.0.5.0/24", "10.0.6.0/24" ]
}

#Default Availability Zone
variable "availability_zone" {
  type = list(string)
  description = "Availability Zone"
  default = [ "ap-southeast-1a", "ap-southeast-1b" ]
}

#Default AMI ID for EC2
variable "ami_id" {
  type = string
  description = "AMI ID for EC2"
  default = "ami-049731af5cd9af3ec"
}

#Default Instace type for EC2
variable "instace_type" {
  type = string
  description = "Instace type for EC2"
  default = "t2.micro"
}

#Default username used for DB
variable "db_username" {
  type = string
  description = "DB root user username"
  default     = "admin"
}

#Default password for DB
variable "db_password" {
  type = string
  description = "DB root user password"
  default     = "Elvin1234!"
}
