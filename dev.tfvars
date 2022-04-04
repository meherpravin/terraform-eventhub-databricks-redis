azure = {
  subscription_id = ""
  tenant_id       = ""
}

eventhub_namespaces = {
  client_ids         = [""]
  resource_name      = "test-eh"
  net_security_group = "test"
  net_subnet         = "test"

  namespaces = {
    test_env = {
      name          = "test"
      sku           = "Standard"
      max_capacity  = 20
      hubs          = {
        test = {
          partition_count   = 4
          message_retention = 1
        },
      }
      ad_app_principal_id   = ""
    }
  }
}

location = "westeurope"

default_tags = {
  environment = "dev"
}

network = {
  vnet    = ""
  rg_vnet = ""
}

keyvault = {
  name        = ""
}

services = {
  name   = "services"
  subnet = [""]
}

redis_subnet = {
    name        = "snet-redis"
    subnet      = [""]
}

aks_test_staging = {
  name            = "test"
}
