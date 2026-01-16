terraform {
  backend "s3" {
    bucket         = "imran-terraform-state-us-east-2-2026"
    key            = "multiple-ec2/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
