
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_iam_user" "current_user" {
  user_name = var.aws_user
}