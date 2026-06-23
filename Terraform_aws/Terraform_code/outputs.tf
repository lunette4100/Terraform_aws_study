output "vpc_id" {
  description = "VPC_ID"
  value       = aws_vpc.vpc.id
}
output "aws_subnet_id" {
  description = "PublicsubnetA_ID"
  value       = aws_subnet.publicsubnet_A.id
}
output "ec2_instance_id" {
  description = "EC2 Instance_ID"
  value       = aws_instance.tf_ec2.id
}
output "ec2_public_ip" {
  description = "EC2 Public_IP"
  value       = aws_instance.tf_ec2.public_ip
}
output "rds_endpoint" {
  description = "RDS_endpoint_address"
  value       = aws_db_instance.rds.address
}
output "rds_port" {
  description = "RDS_endpoint_port"
  value       = aws_db_instance.rds.port
}
output "alb_url" {
  description = "ALB_endpoint_URL"
  value       = "http://${aws_lb.alb.dns_name}"
}