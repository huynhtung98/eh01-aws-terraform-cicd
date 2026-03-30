# Create App Tier NLB Security Group
resource "aws_security_group" "eh01-sg-iznlb" {
  name        = "eh01-sg-iznlb"
  description = "SG for internal app NLB"
  vpc_id      = aws_vpc.eh01-vpc-threetier.id
    
    ingress {
        description = "Allow traffic from Web server"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        security_groups = [aws_security_group.eh01-sg-ezweb.id]
  }

    egress {
    description = "Oubound traffic to App server"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]

  }

  tags = {
    Name = "eh01-sg-iznlb"
  }
}



# Create App Tier Security Group
resource "aws_security_group" "eh01-sg-izapp" {
  name        = "eh01-sg-izapp"
  description = "SG for internal app tier"
  vpc_id      = aws_vpc.eh01-vpc-threetier.id

    ingress {
        description = "Allow inbound traffic"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        security_groups = [aws_security_group.eh01-sg-iznlb.id]
  }  

    ingress {
        description = "Allow inbound traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.eh01-sg-iznlb.id]
  }


    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]

  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eh01-sg-izapp"
  }
}




# Create apptier launch template
resource "aws_launch_template" "App-template" {
  name = "App-launch-template"
  description = "App tier Launch template"
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
    security_groups = [aws_security_group.eh01-sg-izapp.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App tier Launch template"
    }
  }

  #######user_data = filebase64("${path.module}/app_setup.sh")##########
  user_data = base64encode(templatefile("${path.module}/app_db.sh", {
  DB_HOST = aws_db_instance.eh01_rds_mysql.address
}))


}

# Create Apptier NLB
resource "aws_lb" "eh01_izapp_nlb" {
  name               = "eh01-izapp-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.eh01_sub_izapp : subnet.id]
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
  vpc_id   = aws_vpc.eh01-vpc-threetier.id
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

# Create Apptier autoscaling group
resource "aws_autoscaling_group" "eh01-izapp-asg" {
  name                      = "eh01-izapp-asg"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  target_group_arns         = [ aws_lb_target_group.iznlb-tg.arn ]  
  vpc_zone_identifier       = [for subnet in aws_subnet.eh01_sub_izapp : subnet.id]
  launch_template {
    id      = aws_launch_template.App-template.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "eh01-ec2-izapp-asg"
    propagate_at_launch = true
  }

}
