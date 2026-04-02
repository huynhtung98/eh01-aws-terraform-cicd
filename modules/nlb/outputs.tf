output "nlb_dns" {
  value = aws_lb.eh01_izapp_nlb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.iznlb-tg.arn
}