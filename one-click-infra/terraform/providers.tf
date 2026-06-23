terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote S3 backend to store the terraform.tfstate file
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique"
    key            = "monitoring/state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # Optional: DynamoDB for state locking
  }
}

provider "aws" {
  region = var.aws_region
}
