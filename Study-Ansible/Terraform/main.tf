resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-study-vpc"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-study-igw"
  }

}
resource "aws_subnet" "publicsubnet_A" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.default_az[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-publicsubnet-a"
  }

}
resource "aws_subnet" "publicsubnet_B" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.default_az[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-publicsubnet-b"
  }

}

resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "route" {
  route_table_id         = aws_route_table.routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public-routetable-a" {
  subnet_id      = aws_subnet.publicsubnet_A.id
  route_table_id = aws_route_table.routetable.id
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

resource "aws_instance" "tf_ec2" {
  ami           = "ami-0f18986364089c4ab"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.publicsubnet_A.id
  vpc_security_group_ids = [
    aws_security_group.ec2_ssh.id
  ]
  key_name = var.key_name

  tags = {
    Name = "terraform-ec2"
  }

}