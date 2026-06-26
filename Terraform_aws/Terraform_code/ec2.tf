resource "aws_instance" "tf_ec2" {
  ami           = "ami-0f18986364089c4ab"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.publicsubnet_A.id
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,
    aws_security_group.ec2_ssh.id,
  ]
  key_name = var.key_name

  tags = {
    Name = "terraform-ec2"
  }
  
}

resource "aws_iam_role" "ssm_ec2_iam_role" {
  name = "ssm_ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_core" {
  role       = aws_iam_role.ssm_ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ec2_instance_profile_ssm" {
  name = "ec2_instance_profile_ssm"
  role = aws_iam_role.ssm_ec2_iam_role.name
}

