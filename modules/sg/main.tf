# Create Web Tier ALB Security Group
resource "aws_security_group" "eh01_sg_ezalb" {
  name        = "eh01-sg-ezalb"
  description = "SG for internet-facing ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to web tier"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "eh01-sg-ezalb"
  }
}

# Create Web Tier Security Group
resource "aws_security_group" "eh01_sg_ezweb" {
  name        = "eh01-sg-ezweb"
  description = "SG for web tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eh01_sg_ezalb.id]
  }

  egress {
    description = "App traffic to NLB / app tier"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidrs
  }

  egress {
    description = "HTTPS for package installs and SSM"
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

  # Web -> NLB -> App. The NLB preserves the client source IP for instance
  # targets, so we allow traffic from the web tier SG directly.
  ingress {
    description     = "App traffic from web tier via NLB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.eh01_sg_ezweb.id]
  }

  # NLB health checks originate from the NLB nodes inside the app subnets
  ingress {
    description = "Health checks from NLB nodes"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.app_subnet_cidrs
  }

  egress {
    description = "HTTPS for package installs and SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "MySQL to DB tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eh01_sg_izdb.id]
  }

  tags = {
    Name = "eh01-sg-izapp"
  }
}

# Database Tier Security Group
resource "aws_security_group" "eh01_sg_izdb" {
  name        = "eh01-sg-izdb"
  description = "SG for database tier"
  vpc_id      = var.vpc_id

  tags = {
    Name = "eh01-sg-izdb"
  }
}

# Defined as a separate rule (instead of inline on the SG) to avoid a
# circular dependency between the app and db security groups.
resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  description              = "MySQL from app tier only"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eh01_sg_izdb.id
  source_security_group_id = aws_security_group.eh01_sg_izapp.id
}
