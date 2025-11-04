# Used cloud providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.12.0"


}

# Terraform will automatically use whatever account logged in
# and the subscription currently set
provider "azurerm" {
  features {}
}
