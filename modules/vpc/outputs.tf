output "vpc_id" {
  value = aws_vpc.eh01_vpc_threetier.id
}

output "vpc_cidr" {
  value = aws_vpc.eh01_vpc_threetier.cidr_block
}

output "public_web_subnets" {
  description = "Public subnets for the ALB and web tier"
  value       = aws_subnet.eh01_sub_ezweb[*].id
}

output "private_app_subnets" {
  description = "Private subnets for the internal NLB and app tier"
  value       = aws_subnet.eh01_sub_izapp[*].id
}

output "private_app_subnet_cidrs" {
  description = "CIDR blocks of the app tier subnets (used for NLB ingress rules)"
  value       = aws_subnet.eh01_sub_izapp[*].cidr_block
}

output "private_db_subnets" {
  description = "Private subnets for the RDS instance"
  value       = aws_subnet.eh01_sub_izdb[*].id
}
