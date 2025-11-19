resource "azurerm_eventhub_namespace" "lab" {
  name                = "ehns${var.lab}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "lab" {
  name              = "eh${var.lab}"
  namespace_id      = azurerm_eventhub_namespace.lab.id
  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_consumer_group" "lab" {
  name                = "ehcg${var.lab}"
  namespace_name      = azurerm_eventhub_namespace.lab.name
  eventhub_name       = azurerm_eventhub.lab.name
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_eventhub_namespace_authorization_rule" "lab" {
  name                = "authrule${var.lab}"
  namespace_name      = azurerm_eventhub_namespace.lab.name
  resource_group_name = azurerm_resource_group.lab.name
  listen              = true
  send                = true
  manage              = false
}