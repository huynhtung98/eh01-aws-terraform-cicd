# Apptier launch template
resource "aws_launch_template" "App-template" {
  name          = "App-launch-template"
  description   = "App tier Launch template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile
  }

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    # App tier is in private subnets; outbound traffic goes through the NAT GW
    associate_public_ip_address = false
    security_groups             = [var.sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eh01-ec2-izapp"
    }
  }

  user_data = base64encode(templatefile("${path.module}/app_db.sh", {
    DB_HOST     = var.db_host
    DB_NAME     = var.db_name
    DB_USERNAME = var.db_username
    DB_PASSWORD = var.db_password
  }))
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
  target_group_arns         = [var.target_group_arn]
  vpc_zone_identifier       = var.subnets

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
