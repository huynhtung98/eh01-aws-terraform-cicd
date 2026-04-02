# Create Apptier NLB
resource "aws_lb" "eh01_izapp_nlb" {
  name                       = "eh01-izapp-nlb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.subnets
  enable_deletion_protection = false

  tags = {
    Name = "NLB for App tier"
  }
}

# Create Apptier NLB target group
resource "aws_lb_target_group" "iznlb-tg" {
  name     = "iznlb-tg"
  port     = 8080
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

# Create Apptier NLB listener
resource "aws_lb_listener" "iznlb-listener" {
  load_balancer_arn = aws_lb.eh01_izapp_nlb.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.iznlb-tg.arn
  }
}