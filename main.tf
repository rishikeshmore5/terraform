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

# 1. User Prompt Creation
resource "genesyscloud_architect_user_prompt" "welcome_prompt2" {
  name        = "WelcomeGreeting"
  description = "A simple welcome greeting for callers"
  resources {
    language   = "en-us"
    tts_string = "Thank you for calling. Please wait while we connect you to an agent."
  }
}

# 2. Routing Queue (Fixed: Using flat attributes instead of acw_settings block)
resource "genesyscloud_routing_queue" "test_queue2" {
  name                = "queuefromRishi"
  scoring_method      = "TimestampAndPriority"
  acw_wrapup_prompt   = "MANDATORY"
  acw_timeout_ms      = 30000
}

# 3. Data Action Integration (The Container)
resource "genesyscloud_integration" "web_services_integration" {
  intended_state   = "ENABLED"
  integration_type = "custom-rest-lookup-invoker"
  config {
    name = "External API Integration"
  }
}

# 4. Data Action (Fixed: Added required contract_input and contract_output)
resource "genesyscloud_integration_action" "get_customer_data2" {
  name           = "Get Customer Loyalty Status"
  category       = "CustomerService"
  integration_id = genesyscloud_integration.web_services_integration.id

  # Defines the expected input (e.g., a Customer ID string)
  contract_input = jsonencode({
    "type" = "object",
    "properties" = {
      "customerId" = { "type" = "string" }
    }
  })

  # Defines the expected output (e.g., a Loyalty Tier string)
  contract_output = jsonencode({
    "type" = "object",
    "properties" = {
      "loyaltyTier" = { "type" = "string" }
    }
  })

  config_request {
    request_url_template = "https://api.example.com/customers/$${input.customerId}"
    request_type         = "GET"
  }

  config_response {
    success_template = "{ \"loyaltyTier\": $${successTemplateUtils.firstNonnull($${status}, \"unknown\")} }"
    translation_map = {
      status = "$.loyaltyTier"
    }
  }
}
