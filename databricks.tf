resource "azurerm_resource_group" "rg" {
  name     = "rg-databricks-workspace"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "workspace" {
  name                = "test"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
}

resource "azurerm_role_assignment" "owner" {
  for_each             = toset(var.databricks_owners)
  scope                = azurerm_databricks_workspace.workspace.id
  role_definition_name = "Owner"
  principal_id         = each.key
}