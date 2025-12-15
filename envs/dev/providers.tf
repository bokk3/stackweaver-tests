terraform {
  backend "remote" {
    hostname     = "stack.truyens.pro"
    organization = "mike"
    token        = ""
    workspaces {
      name = "dev-deprecated-test"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0.0,<7.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Using default credentials or environment variables
}

