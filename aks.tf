resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.company}-${var.environment}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.company}-${var.environment}-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = var.environment
    company     = var.company
  }
}

data "azurerm_user_assigned_identity" "aks_agent_pool" {
  name                = "${azurerm_kubernetes_cluster.aks.name}-agentpool"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
}
