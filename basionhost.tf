# Create Bastion Host Security Group
resource "aws_security_group" "eh01-sg-izsub-basionhost" {
  name        = "eh01-sg-izsub-basionhost"
  description = "Allow SSH connect to servers"
  vpc_id      = aws_vpc.eh01-vpc-threetier.id

  # For security reasons, bastion host should only allow from specific IP address. But for the ease of testing, we have allow ssh from anywhere
  ingress {
    description = "ssh from anywhere "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}


# Create Bastion Host instance
resource "aws_instance" "eh01-ec2-izmgmt-bastionhost" {
    ami                         = var.ami_id
    associate_public_ip_address = true
    instance_type               = var.instace_type
    key_name                    = aws_key_pair.ehkey_pair_threetier.key_name
    security_groups             = [aws_security_group.eh01-sg-izsub-basionhost.id]
    subnet_id                   = aws_subnet.eh01_sub_ezweb[0].id

    lifecycle {
    #prevent_destroy = true
    ignore_changes  = [ami, user_data, subnet_id, security_groups]
    }

    tags = {
      Name = "Bastion Host"
    }
}