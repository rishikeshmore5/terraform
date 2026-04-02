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

# 1. Create a User Prompt
resource "genesyscloud_architect_user_prompt" "welcome_prompt" {
  name        = "WelcomeGreeting2"
  description = "A simple welcome greeting for callers"
  resources {
    language   = "en-us"
    tts_string = "Thank you for calling. Please wait while we connect you to an agent."
  }
}

# 2. Create the Routing Queue
resource "genesyscloud_routing_queue" "test_queue" {
  name           = "queuefromRishi2"
  scoring_method = "Timestamp"
  acw_settings {
    wrapup_prompt = "MANDATORY"
    timeout_ms    = 30000
  }
}

# 3. Create a Data Action Integration (Web Services)
resource "genesyscloud_integration" "web_services_integration" {
  intended_state   = "ENABLED"
  integration_type = "custom-rest-lookup-invoker" # Standard Web Services Data Action
  config {
    name = "External API Integration"
  }
}

# 4. Create the Data Action
resource "genesyscloud_integration_action" "get_customer_data" {
  name           = "Get Customer Loyalty Status2"
  category       = "CustomerService"
  integration_id = genesyscloud_integration.web_services_integration.id

  config_request {
    request_url_template = "https://api.example.com/customers/$${input.customerId}"
    request_type         = "GET"
    # Note: Use double dollar signs ($$) for variables to escape Terraform interpolation
  }

  config_response {
    success_template = "{ \"status\": $${successTemplateUtils.firstNonnull($${status}, \"unknown\")} }"
    translation_map = {
      status = "$.loyaltyTier"
    }
  }
}
