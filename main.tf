terraform {
  backend "azurerm" {
    resource_group_name  = "jonnychipz-infra"
    storage_account_name = "jonnychipztstatead"
    container_name       = "tstate"
    key                  = "R0VhwSw01njKZBVVGzL3lMl85GSt/DlfEyYjoB9St6YMRjc6CDhuyDsK/t6L2efPjKycO80zyGZL+ASt3axscw=="
  }

  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source  = "hashicorp/azurerm"
      version = ">= 2.4.1"
    }
  }
}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
data "azurerm_client_config" "current" {}
# Create our Resource Group - aws-pre-RG
resource "azurerm_resource_group" "rg" {
  name     = "aws-pre-app01"
  location = "Korea Central"
}
# Create our Virtual Network - aws-pre-VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "aws-prevnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# Create our Subnet to hold our VM - Virtual Machines
resource "azurerm_subnet" "sn" {
  name                 = "VM"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create our Azure Storage Account - awspresa
resource "azurerm_storage_account" "awspresa" {
  name                     = "awspresa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "aws-prerox1"
  }
}
# Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "aws-prevm01nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create our Virtual Machine - aws-pre-VM01
resource "azurerm_virtual_machine" "aws-prevm01" {
  name                  = "aws-prevm01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_B1s"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }
  storage_os_disk {
    name              = "aws-prevm01os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "aws-prevm01"
    admin_username = "imtiaza"
    admin_password = "$$Lahore!@#$$"
  }
  os_profile_windows_config {
  }
}
