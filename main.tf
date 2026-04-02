terraform {
  cloud {
    organization = "TCLV2"
    workspaces {
      name = "TCLWS"
    }
  }

  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud"
      version = "~> 1.0"
    }
  }
}

provider "genesyscloud" {}

resource "genesyscloud_routing_queue" "test_queue" {
  name = "Test Queue from Terraform"
}