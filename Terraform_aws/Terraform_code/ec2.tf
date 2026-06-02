resource "aws_instance" "tf_ec2" {
  ami           = "ami-0f18986364089c4ab"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.publicsubnetA.id
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,
    aws_security_group.ec2_ssh.id,
  ]
  key_name = var.key_name

  tags = {
    Name = "terraform-ec2"
  }
  
}

