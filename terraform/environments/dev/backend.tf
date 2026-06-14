terraform {
  backend "s3" {
    bucket         = "fastapi-cicd-tfstate-bucket"
    key            = "fastapi-cicd-tfstate-bucket/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
  }
}
