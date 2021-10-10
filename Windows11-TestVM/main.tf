// single-line comments use double slash...
# ...or pound symbol

/* Multi-line comments
use this
thing
*/


# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}



// Define the resource group to be created
resource "azurerm_resource_group" "rg" {
  name     = "rgW11test1"
  location = "westcentralus"
}

// Create a virtual network
resource "azurerm_virtual_network" "network0" {
  name                = "vnet-test-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

// Create a subnet
resource "azurerm_subnet" "subnet0" {
  name                 = "vnet-test-main-subnet0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network0.name
  address_prefixes     = ["10.0.0.0/24"]
}

// Create a second subnet
/* resource "azurerm_subnet" "subnet1" {
  name                 = "vnet-test-main-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network0.name
  address_prefixes     = ["10.0.1.0/24"]
} */

// Create a virtual machine
resource "azurerm_network_interface" "nic0" {
  name                = "w11pro-test-001-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm0" {
  name                = "w11pro-test-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "testadmin"
  admin_password      = "!Thisisatest^0014!"
  network_interface_ids = [
    azurerm_network_interface.nic0.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "Win11-21H2-Pro"
    version   = "latest"
  }
  } // end virtual machine block def