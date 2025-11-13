# Configure the Azure Provider
# Use az to authenticate
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.50.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "cd67b3f6-ee64-425d-9784-b6c5d9170ea0"
}
