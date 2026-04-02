# Create Webtier application load balancer
resource "aws_lb" "eh01-ezalb" {
  name               = "eh01-ezalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnets
}

# Create Webtier application load balancer target group
resource "aws_lb_target_group" "ezalb-tg" {
  name     = "ezalb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Create Webtier application load balancer listener
resource "aws_lb_listener" "ezalb-listener" {
  load_balancer_arn = aws_lb.eh01-ezalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ezalb-tg.arn
  }
}