
variable "cidr_block" {
  description = "Cidr block for VPC "
  default = "10.0.0.0/16"
}
variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}
variable "default_az" {
  description = "Default availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}
variable "rds_password" {
  description = "RDS Password"
  type        = string
  sensitive   = true
}

variable "sns_email_address" {
  description = "e-mail address CloudWatch Alarm"
  type        = string
}


