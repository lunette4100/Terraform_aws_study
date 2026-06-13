terraform {

  backend "s3" {
    bucket = "terraform-study-momo"
    key    = "ansible-study-tf.tfstate"
    region = "ap-northeast-1"
  }

}