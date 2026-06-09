resource "aws_db_subnet_group" "rds-subnet" {
  name       = "rds-subnet"
  subnet_ids = [aws_subnet.privatesubnet_A.id, aws_subnet.privatesubnet_B.id]
  tags = {
    Name = "RDS subnet group"
  }
}
resource "aws_db_instance" "rds" {
  allocated_storage          = 10
  db_name                    = "terraform_rds"
  engine                     = "mysql"
  engine_version             = "8.0"
  auto_minor_version_upgrade = true
  instance_class             = "db.t3.micro"
  username                   = "admin"
  password                   = var.rds_password
  parameter_group_name       = "default.mysql8.0"
  skip_final_snapshot        = true
  db_subnet_group_name       = aws_db_subnet_group.rds-subnet.name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  availability_zone          = null
  multi_az                   = true
  publicly_accessible        = false
  deletion_protection        = true
  backup_retention_period    = 1

  tags = {
    Name = "terraform-rds"
  }
  
}