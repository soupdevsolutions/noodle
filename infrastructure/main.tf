terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.51.0"
    }
    stripe = {
      source  = "franckverrot/stripe"
      version = "1.9.0"
    }
  }

  backend "s3" {
    bucket = "noodle-tf-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }

  required_version = ">= 1.5.4"
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "aws" {
  alias      = "us"
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "stripe" {
  api_token = var.STRIPE_API_KEY
}
