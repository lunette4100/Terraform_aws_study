
variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}
variable "default_az" {
  description = "Default availability zone"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}
variable "rds_password" {
  description = "RDSpassword"
  type        = string
  sensitive   = true
}

variable "cloudwatch_alarm" {
  type    = string
  default = "arn:aws:sns:ap-northeast-1:381155823609:Topic"
}



