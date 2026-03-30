output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.eh01-ezalb.dns_name
}

output "IP_BasionHost" {
  description = "The Basion Host IP address"
  value = aws_instance.eh01-ec2-izmgmt-bastionhost.public_ip
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.eh01_rds_mysql.endpoint
}
