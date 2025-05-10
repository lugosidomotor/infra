resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.company}-${var.environment}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.company}-${var.environment}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.company}-${var.environment}-aks"
  
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    min_count  = 1
    max_count  = 5
  }
  
  role_based_access_control_enabled = true
  
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }
  
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }
  
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
  
  identity {
    type = "SystemAssigned"
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
