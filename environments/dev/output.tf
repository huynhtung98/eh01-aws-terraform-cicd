output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns" {
  value = module.alb.alb_dns
}

output "nlb_dns" {
  value = module.nlb.nlb_dns
}

output "web_asg_name" {
  value = module.asg_web.web_asg_name
}

output "app_asg_name" {
  value = module.asg_app.app_asg_name
}