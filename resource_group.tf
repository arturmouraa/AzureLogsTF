# Create the Resource Group
resource "azurerm_resource_group" "lab" {
  name     = "RG${var.lab}"
  location = var.location
}