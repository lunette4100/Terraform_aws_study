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
resource "aws_subnet" "publicsubnetA" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.default_az[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-publicsubnet-a"
  }
}
resource "aws_subnet" "publicsubnetB" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.default_az[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-publicsubnet-b"
  }
}
resource "aws_subnet" "privatesubnetA" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = var.default_az[0]
  tags = {
    Name = "terraform-privatesubnet-a"
  }
}
resource "aws_subnet" "privatesubnetB" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = var.default_az[1] 
  tags = {
    Name = "terraform-privatesubnet-b"
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
  subnet_id      = aws_subnet.publicsubnetA.id
  route_table_id = aws_route_table.routetable.id
}
resource "aws_route_table_association" "public-routetable-b" {
  subnet_id      = aws_subnet.publicsubnetB.id
  route_table_id = aws_route_table.routetable.id
}