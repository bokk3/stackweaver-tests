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
    local = {
      source  = "hashicorp/local"
      version = "~> 1.0"
    }
  }
}
