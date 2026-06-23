terraform {

  backend "s3" {
    bucket = "terraform-study-momo"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
  
}