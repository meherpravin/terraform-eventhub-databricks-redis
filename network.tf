resource "azurerm_virtual_network" "vnet" {
  name                 = var.network.vnet
  resource_group_name  = var.network.rg_vnet
  address_space        = []
  location             = ""
}

resource "azurerm_subnet" "eventhub_namespaces" {
  name                                           = "snet-${var.eventhub_namespaces.net_security_group}"
  resource_group_name                            = var.network.rg_vnet
  virtual_network_name                           = var.network.vnet
}

resource "azurerm_subnet" "services" {
  name                                           = "snet-${var.services.name}"
  resource_group_name                            = var.network.rg_vnet
  virtual_network_name                           = var.network.vnet
}

# Redis cache subnet
resource "azurerm_subnet" "redis_subnet" {
  name                                           = var.redis_subnet.name
  enforce_private_link_endpoint_network_policies = true
  resource_group_name                            = var.network.rg_vnet
  virtual_network_name                           = var.network.vnet
  address_prefixes                               = var.redis_subnet.subnet
}