## declare here the resources for your landing zone

resource "azurerm_policy_assignment" "require-tag-managedby" {
  count = var.policy.enable_require_custom-tag ? 1 : 0
  name                 = "require-managed-by-tag"
  scope                = data.azurerm_subscription.primary.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  display_name         = "Require the managedBy tag on resource groups"
  location             = var.location
  identity { type = "SystemAssigned" }
  parameters = <<PARAMETERS
    {
      "tagName": {
        "value": "${var.policy.managedby_tag}"
    }
    }
  PARAMETERS
}