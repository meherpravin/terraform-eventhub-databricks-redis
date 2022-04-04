locals {
  eventhubs_to_clients = flatten([
  for namespace_key, namespace in var.eventhub_namespaces.namespaces : [
  for client in var.eventhub_namespaces.client_ids : {
    namespace_key = namespace_key
    client_id     = client
  }
  ]
  ])
}

resource "azurerm_role_assignment" "user_eventhub" {
  for_each = {
  for ra in local.eventhubs_to_clients : "${ra.namespace_key}${ra.client_id}" => ra
  }
  scope                = azurerm_eventhub_namespace.test_ns[each.value.namespace_key].id
  role_definition_name = "Azure Event Hubs Data Owner"
  principal_id         = each.value.client_id
}
