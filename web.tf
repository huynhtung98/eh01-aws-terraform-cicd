# Create Web Tier ALB Security Group
resource "aws_security_group" "eh01-sg-ezalb" {
  name        = "eh01-sg-ezalb"
  description = "SG for internet ALB"
  vpc_id      = aws_vpc.eh01-vpc-threetier.id

    ingress {
        description = "HTTP from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eh01-sg-ezalb"
  }
}

# Create Web Tier Security Group
resource "aws_security_group" "eh01-sg-ezweb" {
  name        = "eh01-sg-ezweb"
  description = "SG for internet web tier"
  vpc_id      = aws_vpc.eh01-vpc-threetier.id

    ingress {
        description = "HTTPs from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.eh01-sg-ezalb.id]
  }


    egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "eh01-sg-ezweb"
  }
}


# Create a webtier launch template
resource "aws_launch_template" "Ezweb-launch-template" {
  name = "Ezweb-launch-template"
  description = "Web tier Launch template"
  image_id = var.ami_id
  instance_type = var.instace_type
  key_name = aws_key_pair.ehkey_pair_threetier.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  metadata_options {
    http_endpoint = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.eh01-sg-ezweb.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web tier Launch template"
    }
  }

 user_data = base64encode(
  templatefile("${path.module}/apache_web_install.sh", {
    NLB_DNS = aws_lb.eh01_izapp_nlb.dns_name
  })
)
}

# Create Webtier application load balancer
resource "aws_lb" "eh01-ezalb" {
  name               = "eh01-ezalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.eh01-sg-ezalb.id]
  subnets            = [for subnet in aws_subnet.eh01_sub_ezweb : subnet.id]
}

# Create Webtier application load balancer target group
resource "aws_lb_target_group" "ezalb-tg" {
  name     = "ezalb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.eh01-vpc-threetier.id
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

# Create Webtier autoscaling group
resource "aws_autoscaling_group" "eh01-ezweb-asg" {
  name                      = "eh01-ezweb-asg"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  target_group_arns         = [ aws_lb_target_group.ezalb-tg.arn ]  
  vpc_zone_identifier       = [for subnet in aws_subnet.eh01_sub_ezweb : subnet.id]
  launch_template {
    id      = aws_launch_template.Ezweb-launch-template.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "eh01-ec2-ezweb-asg"
    propagate_at_launch = true
  }

}

# Creating the AWS Cloudwatch Alarm that will scale up when CPU utilization increase.


# Creating the AWS Cloudwatch Alarm that will scale down when CPU utilization decrease.

