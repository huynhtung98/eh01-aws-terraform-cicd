# Create Database Tier Security Group
resource "aws_security_group" "eh01-sg-db" {
  name        = "eh01-sg-db"
  description = "Security group for DB"
  vpc_id      = aws_vpc.eh01-vpc-threetier.id

  # Allow inbound MySQL from App Tier only
  ingress {
    description      = "MySQL from App Tier"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.eh01-sg-izapp.id] 
  }

  # Outbound open
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eh01-sg-db"
  }
}

# Create DB Subnet Group 
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "eh01-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.eh01_sub_izdb : subnet.id]

  tags = {
    Name = "eh01-db-subnet-group"
  }
}

# Create Database Instance
resource "aws_db_instance" "eh01_rds_mysql" {
  identifier             = "eh01-rds-mysql"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"         # Free Tier eligible
  username               = var.db_username
  password               = var.db_password
  db_name                = "labdb"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.eh01-sg-db.id]
  publicly_accessible    = false
  multi_az               = true                 
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "eh01-rds-mysql"
  }
}

