terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.55.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.4.1"
    }
    helm = {
      source  = "helm"
      version = "=2.4.1"
    }
  }
}


provider "azurerm" {
  #  subscription_id = ""
  #  tenant_id       = ""
  features {}
}

