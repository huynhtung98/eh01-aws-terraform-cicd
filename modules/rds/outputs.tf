output "db_endpoint" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.eh01_rds_mysql.address
}

output "db_name" {
  value = aws_db_instance.eh01_rds_mysql.db_name
}
