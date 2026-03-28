terraform {
  cloud {
    organization = "TCLV2"

    workspaces {
      name = "TCLWS"
    }
  }

  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

provider "genesyscloud" {}

resource "genesyscloud_routing_queue" "test_queue" {
  name = "queuefromRishi"
}
