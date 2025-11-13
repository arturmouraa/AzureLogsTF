# Output to facilitate future reference
output "event_hub_name" {
  value = azurerm_eventhub.lab.name
}

output "ConsumerGroup" {
  value = azurerm_eventhub_consumer_group.lab.name
}

data "azurerm_eventhub_namespace_authorization_rule" "lab" {
  name                = azurerm_eventhub_namespace_authorization_rule.lab.name
  namespace_name      = azurerm_eventhub_namespace.lab.name
  resource_group_name = azurerm_resource_group.lab.name

}

output "connectionString" {
  value     = nonsensitive(data.azurerm_eventhub_namespace_authorization_rule.lab.primary_connection_string)
  sensitive = false
}

output "storageaccount" {
  value = azurerm_storage_account.lab.name
}

output "storage_account_key" {
  value     = nonsensitive(azurerm_storage_account.lab.primary_access_key)
  sensitive = false
}