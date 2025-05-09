resource "azurerm_postgresql_flexible_server" "postgres" {
  name                          = "${var.company}-${var.environment}-postgresql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  administrator_login           = "adminTerraform"
  administrator_password        = random_password.postgres_admin_password.result
  storage_mb                    = 32768
  version                       = "12"
  sku_name                      = "B_Standard_B2ms"
  zone                          = "2"
  public_network_access_enabled = true

  authentication {
    active_directory_auth_enabled = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  tags = {
    environment = var.environment
    company     = var.company
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all_azure_services" {
  name             = "AllowAllAzureServices"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "postgres_admin" {
  server_name         = azurerm_postgresql_flexible_server.postgres.name
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_service_principal.postgreAdmin.object_id
  principal_name      = data.azuread_service_principal.postgreAdmin.display_name
  principal_type      = "ServicePrincipal"
}
