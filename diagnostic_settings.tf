resource "azurerm_monitor_aad_diagnostic_setting" "lab" {
  name               = "ds${var.lab}"
  eventhub_name = azurerm_eventhub.lab.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.lab.id
  enabled_log {
    category = "SignInLogs"
  }
}