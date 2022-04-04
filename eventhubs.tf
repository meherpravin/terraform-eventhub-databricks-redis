resource "azurerm_resource_group" "keyvault" {
  name     = "rg-${var.keyvault.name}-${var.location}"
  location = var.location

  tags = var.default_tags
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "kv-${var.keyvault.name}-01"
  resource_group_name         = data.azurerm_resource_group.keyvault.name
}

resource "azurerm_resource_group" "eventhub_namespaces" {
  name     = "rg-${var.eventhub_namespaces.resource_name}-${var.location}"
  location = var.location
}

resource "azurerm_eventhub_namespace" "test_ns" {
  for_each                 = var.eventhub_namespaces.namespaces
  name                     = "ehn-${each.value.name}-${var.location}"
  location                 = azurerm_resource_group.eventhub_namespaces.location
  resource_group_name      = azurerm_resource_group.eventhub_namespaces.name
  sku                      = each.value.sku
  auto_inflate_enabled     = true
  maximum_throughput_units = each.value.max_capacity

  network_rulesets {
    default_action = "Deny"
    trusted_service_access_enabled = true
  }

  tags = var.default_tags
}

locals {
  event_hubs = flatten([
    for namespace_key, namespace in var.eventhub_namespaces.namespaces : [
      for hub_key, hub in namespace.hubs : {
        namespace         = "ehn-${namespace.name}-${var.location}"
        hub_name          = hub_key
        hub               = hub
      }
    ]
  ])
}

resource "azurerm_eventhub" "test_ns" {
  for_each = {
    for eh in local.event_hubs : "${eh.namespace}${eh.hub_name}" => eh
  }
  name                = each.value.hub_name
  namespace_name      = each.value.namespace
  resource_group_name = azurerm_resource_group.eventhub_namespaces.name
  partition_count     = each.value.hub.partition_count
  message_retention   = each.value.hub.message_retention
}

resource "azurerm_eventhub_namespace_authorization_rule" "producer_ns" {
  for_each            = azurerm_eventhub_namespace.test_ns
  name                = "producer-${each.value.name}"
  namespace_name      = each.value.name
  resource_group_name = azurerm_resource_group.eventhub_namespaces.name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_private_endpoint" "test_ns" {
  for_each            = azurerm_eventhub_namespace.test_ns
  name                = format("pe-%s", each.value.name)
  location            = azurerm_resource_group.eventhub_namespaces.location
  resource_group_name = azurerm_resource_group.eventhub_namespaces.name
  subnet_id           = resource.azurerm_subnet.eventhub_namespaces.id

  private_service_connection {
    name                           = format("pes-%s", each.value.name)
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names = ["namespace"]
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_key_vault_secret" "test_event_hubs_secret" {
  for_each = azurerm_eventhub_namespace.test_ns

  name         = "${each.value.name}-connection-string"
  value        = azurerm_eventhub_namespace_authorization_rule.producer_ns[each.key].primary_connection_string
  key_vault_id = data.azurerm_key_vault.keyvault.id

  lifecycle {
    ignore_changes = [value]
  }
}


