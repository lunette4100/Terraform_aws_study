resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for EC2 app"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "ec2-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "ec2_in_http" {
  security_group_id            = aws_security_group.ec2_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_sg.id
}
resource "aws_vpc_security_group_ingress_rule" "ec2_in_application" {
  security_group_id            = aws_security_group.ec2_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_sg.id
}
resource "aws_vpc_security_group_egress_rule" "ec2_eg" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_security_group" "ec2_ssh" {
  name        = "ec2-ssh-sg"
  description = "Security group for EC2 SSH access"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "ec2-ssh-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "ec2_in_ssh" {
  security_group_id = aws_security_group.ec2_ssh.id
  cidr_ipv4         = "153.175.16.24/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "ec2_eg_ssh" {
  security_group_id = aws_security_group.ec2_ssh.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_security_group" "rds_sg" {
  name        = "terraform-rds-sg"
  description = "Allow RDS access from application servers"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "rds-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "rds_in" {
  security_group_id            = aws_security_group.rds_sg.id
  description                  = "MySQL from app servers"
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_sg.id
}
resource "aws_vpc_security_group_egress_rule" "rds_eg" {
  security_group_id = aws_security_group.rds_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_security_group" "alb_sg" {
  name        = "terraform-alb-sg"
  description = "Security group for ALB "
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "alb-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "alb_in" {
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "alb_eg" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
