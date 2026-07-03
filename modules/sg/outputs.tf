output "alb_sg_id" {
  value = aws_security_group.eh01_sg_ezalb.id
}

output "web_sg_id" {
  value = aws_security_group.eh01_sg_ezweb.id
}

output "app_sg_id" {
  value = aws_security_group.eh01_sg_izapp.id
}

output "db_sg_id" {
  value = aws_security_group.eh01_sg_izdb.id
}
