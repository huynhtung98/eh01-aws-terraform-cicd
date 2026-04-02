output "alb_dns" {
  value = aws_lb.eh01-ezalb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.ezalb-tg.arn
}
