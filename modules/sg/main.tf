# Create Web Tier ALB Security Group
resource "aws_security_group" "eh01_sg_ezalb" {
  name        = "eh01-sg-ezalb"
  description = "SG for internet ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "eh01-sg-ezalb"
  }
}

# Create Web Tier Security Group
resource "aws_security_group" "eh01_sg_ezweb" {
  name        = "eh01-sg-ezweb"
  description = "SG for internet web tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPs from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eh01_sg_ezalb.id]
  }

  egress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.3.0/24", # NLB subnet 1
      "10.0.4.0/24"  # NLB subnet 2
    ]
  }


  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eh01-sg-ezweb"
  }
}

# App Tier Security Group
resource "aws_security_group" "eh01_sg_izapp" {
  name        = "eh01-sg-izapp"
  description = "SG for internal app tier"
  vpc_id      = var.vpc_id

  # NLB → App
  ingress {
    description = "Allow inbound traffic from NLB subnet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.3.0/24", #NLB subnet 1
      "10.0.4.0/24"  #NLB subnet 2
    ]
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

# Create Bastion Host Security Group
resource "aws_security_group" "eh01_sg_izsub-basionhost" {
  name        = "eh01_sg_izsub-basionhost"
  description = "Allow SSH connect to servers"
  vpc_id      = var.vpc_id

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