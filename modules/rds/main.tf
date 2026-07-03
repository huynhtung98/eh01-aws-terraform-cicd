# Create DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "eh01-db-subnet-group"
  subnet_ids = var.subnets

  tags = {
    Name = "eh01-db-subnet-group"
  }
}

# Create Database Instance
resource "aws_db_instance" "eh01_rds_mysql" {
  identifier             = "eh01-rds-mysql"
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # Free Tier eligible
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.sg_id]
  publicly_accessible    = false
  multi_az               = var.multi_az
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "eh01-rds-mysql"
  }
}
