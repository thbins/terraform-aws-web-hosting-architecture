/*

terraform {
  backend "s3" {
    bucket         = "tfstate-<your-account>-prod"   # 바꿔 넣기
    key            = "web3tier/terraform.tfstate"    # 단일 state 경로
    region         = "ap-northeast-2"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}

*/