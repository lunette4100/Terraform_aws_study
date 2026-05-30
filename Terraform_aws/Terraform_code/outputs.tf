output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "aws_subnet_id" {
  description = "PubricsubnetA ID"
  value       = aws_subnet.pubricsubnetA.id
}


output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.tf_ec2
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.tf_ec2
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.rds.address
}

output "rds_port" {
  description = "RDS endpoint port"
  value       = aws_db_instance.rds.port
}

output "alb_url" {
  description = "ALB endpoint URL"
  value       = "http://${aws_lb.alb.dns_name}"
}