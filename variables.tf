variable azure {
  default = {}
}

variable "databricks_owners" {
  default = [
    "",
    ""
  ]
}

variable eventhub_namespaces {
  default = {
    subnet       = []
    client_ids   = []
    resource_group     = ""
    net_security_group = ""
    net_subnet         = ""

    namespaces = {}
  }
}

variable location {
  default = ""
}

variable "default_tags" {
  default = {}
}

variable network {
  default = {}
}

variable "keyvault" {
  default = ""
}

variable services {
  default = {
    name   = ""
    subnet = []
  }
}

variable redis_subnet {
  default = {
    name        = ""
    subnet      = []
  }
}

variable aks {
  default = {
    name            = ""
  }
}