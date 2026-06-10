run "check_vpc_cidr_and_name" {
  command = plan
  
  assert {
    condition     = aws_vpc.vpc.tags["Name"] == "terraform-study-vpc"
    error_message = "VPC Name タグが terraform-study-vpc ではありません"
  }

  assert {
    condition     = aws_vpc.vpc.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR が 10.0.0.0/16 ではありません"
  }

  assert {
    condition     = aws_subnet.publicsubnet_A.cidr_block == "10.0.1.0/24"
    error_message = "publicsubnet_A CIDR が 10.0.1.0/24 ではありません"
  }

  assert {
    condition     = aws_subnet.publicsubnet_B.cidr_block == "10.0.2.0/24"
    error_message = "publicsubnet_B CIDR が 10.0.2.0/24 ではありません"
  }

  assert {
    condition     = aws_subnet.privatesubnet_A.cidr_block == "10.0.11.0/24"
    error_message = "privatsubnet_A CIDR が 10.0.11.0/24 ではありません"
  }
  assert {
    condition     = aws_subnet.privatesubnet_B.cidr_block == "10.0.12.0/24"
    error_message = "privatesubnet_B CIDR が 10.0.12.0/24 ではありません"
  }

}

run "check_port" {
  command = plan
 
 assert {
    condition     = aws_vpc_security_group_ingress_rule.ec2_in_http.from_port == 80
    error_message = "EC2_from_portが80ではありません"
  }

 assert {
    condition     = aws_vpc_security_group_ingress_rule.alb_in.from_port == 80
    error_message = "alb_from_portが80ではありません"
  }

}
