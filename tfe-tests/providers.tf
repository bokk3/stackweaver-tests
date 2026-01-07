terraform {
  backend "remote" {
    hostname     = "stackweaver.vhco.pro"
    organization = "main"
    token = var.stackweaver_token
    workspaces {
      name = "ws-1q0HQPrGm4Yf1q0H"   # check why this did not error when the workspace did not exist
    }
  }

  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "~> 0.72.0"
    }
  }
}

provider "tfe" {
  hostname = "stackweaver.vhco.pro"
  token    = var.stackweaver_token
}