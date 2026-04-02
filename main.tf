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

# 1. User Prompt
resource "genesyscloud_architect_user_prompt" "welcome_prompt2" {
  name        = "WelcomeGreeting"
  description = "A simple welcome greeting for callers"

  resources {
    language   = "en-us"
    tts_string = "Thank you for calling. Please wait while we connect you to an agent."
  }
}

# 2. Queue (FIXED NAME)
resource "genesyscloud_routing_queue" "test_queue2" {
  name              = "queuefromRishi_v2"   # ✅ changed name
  scoring_method    = "TimestampAndPriority"
  acw_wrapup_prompt = "MANDATORY"
  acw_timeout_ms    = 30000
}

# 3. Integration (FIXED TYPE)
resource "genesyscloud_integration" "web_services_integration" {
  intended_state   = "ENABLED"
  integration_type = "custom-rest-actions"   # ✅ FIXED

  config {
    name = "External API Integration"
  }
}

# 4. Data Action
resource "genesyscloud_integration_action" "get_customer_data2" {
  name           = "Get Customer Loyalty Status"
  category       = "CustomerService"
  integration_id = genesyscloud_integration.web_services_integration.id

  depends_on = [genesyscloud_integration.web_services_integration]

  contract_input = jsonencode({
    type = "object",
    properties = {
      customerId = { type = "string" }
    }
  })

  contract_output = jsonencode({
    type = "object",
    properties = {
      loyaltyTier = { type = "string" }
    }
  })

  config_request {
    request_url_template = "https://api.example.com/customers/$${input.customerId}"
    request_type         = "GET"
  }

  config_response {
    translation_map = {
      loyaltyTier = "$.loyaltyTier"
    }

    success_template = <<EOF
{
  "loyaltyTier": "$${loyaltyTier}"
}
EOF
  }
}