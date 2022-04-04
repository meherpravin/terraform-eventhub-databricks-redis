# Redis resource group
resource "azurerm_resource_group" "redis_rg" {
  name     = "rg-redis-westeurope"
  location = "West Europe"
}

resource "azurerm_redis_cache" "redis_cache" {
  name                          = "test-redis"
  location                      = azurerm_resource_group.redis_rg.location
  resource_group_name           = azurerm_resource_group.redis_rg.name
  capacity                      = 1
  family                        = "C"
  sku_name                      = "Standard"
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
}

resource "azurerm_private_endpoint" "pe_redis_cache" {
  name                = "pe-redis-cache"
  location            = azurerm_resource_group.redis_rg.location
  resource_group_name = azurerm_resource_group.redis_rg.name
  subnet_id           = azurerm_subnet.redis_subnet.id

  private_service_connection {
    name                           = "pes-redis-cache"
    private_connection_resource_id = azurerm_redis_cache.redis_cache.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}


resource "azurerm_key_vault_secret" "pe_redis_cache_secret" {
  name         = "redis-cache-access-key"
  value        = azurerm_redis_cache.redis_cache.primary_access_key
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                                           = "aks-${var.aks.name}-${var.location}"
  resource_group_name                            = "rg-${var.aks.name}-${var.location}"
  location                                       = ""
  default_node_pool {
    name    = ""
    vm_size = ""
  }
}

resource "azurerm_role_assignment" "aks_test_eventhub_redis_role" {
  scope                = azurerm_redis_cache.redis_cache.id
  role_definition_name = "Redis Cache Contributor"
  principal_id         = resource.azurerm_kubernetes_cluster.aks.identity[0].principal_id
}


