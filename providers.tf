# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs
terraform {
  backend "remote" {
    hostname     = "stack.truyens.pro"
    organization = "mike"
    # token = "<YOUR_TOKEN>"
    token = ""
    workspaces {
      name = "mike"
    }
  }

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.0"
    }
  }
}
