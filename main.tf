provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-bucket"
  force_destroy = true
}
