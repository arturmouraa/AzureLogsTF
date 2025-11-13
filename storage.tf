resource "azurerm_storage_account" "lab" {
  name                     = lower("stgacct${var.lab}")
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  is_hns_enabled           = false
}
