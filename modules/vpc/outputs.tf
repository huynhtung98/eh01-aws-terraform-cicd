output "vpc_id" {
  value = aws_vpc.eh01_vpc_threetier.id
}

output "public_subnets" {
  value = aws_subnet.eh01_sub_ezweb[*].id
}

output "private_subnets" {
  value = aws_subnet.eh01_sub_izapp[*].id
}