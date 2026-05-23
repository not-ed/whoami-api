terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.72.0"
    }
  }

  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = true
    storage_account_name = ""
    container_name       = ""
    key                  = "whoami-api.terraform.tfstate"
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "primary" {}

variable "application-name" {
  type    = string
  default = "whoami API"
}

variable "database-administrator-username" {
  type      = string
  sensitive = true
}

variable "database-administrator-password" {
  type      = string
  sensitive = true
}

variable "github-username" {
  type = string
}

resource "azurerm_resource_group" "resource-group-whoami-api" {
  name     = "whoami-api"
  location = "uksouth"
  tags = {
    application = var.application-name
  }
}

resource "azurerm_key_vault" "key-vault-whoami-api" {
  name                = "whoami-keyvault"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  sku_name                      = "standard"
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  rbac_authorization_enabled    = true
}

resource "azurerm_role_assignment" "role-assignment-whoami-api-key-vault-administrator" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "role-assignment-whoami-api-functions-secrets-user" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_function_app_flex_consumption.function-app-flex-consumption-whoami-api.identity[0].principal_id
}

resource "azurerm_role_assignment" "role-assignment-whoami-api-app-service-secrets-user" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.linux-web-app-whoami-api.identity[0].principal_id
}


resource "azurerm_key_vault_secret" "key-vault-secret-whoami-api-github-username" {
  key_vault_id = azurerm_key_vault.key-vault-whoami-api.id
  name         = "Config-GitHub-Username"
  value        = var.github-username
  content_type = "The GitHub username of the User whose events are being stored during ingestion"
}

resource "azurerm_key_vault_secret" "key-vault-secret-whoami-api-database-name" {
  key_vault_id = azurerm_key_vault.key-vault-whoami-api.id
  name         = "Config-DatabaseName"
  value        = azurerm_mssql_database.mssql-database-whoami-api.name
  content_type = "Name of the SQL Database to connect to"
}

resource "azurerm_key_vault_secret" "key-vault-secret-whoami-api-database-password" {
  key_vault_id = azurerm_key_vault.key-vault-whoami-api.id
  name         = "Config-DatabasePassword"
  value        = var.database-administrator-password
  content_type = "The password of the user used to connect to the SQL Server"
}

resource "azurerm_key_vault_secret" "key-vault-secret-whoami-api-database-server-name" {
  key_vault_id = azurerm_key_vault.key-vault-whoami-api.id
  name         = "Config-DatabaseServerName"
  value        = azurerm_mssql_server.mssql-server-whoami-api.fully_qualified_domain_name
  content_type = "Full Database Server Name / URL (e.g. *.database.windows.net)"
}

resource "azurerm_key_vault_secret" "key-vault-secret-whoami-api-database-username" {
  key_vault_id = azurerm_key_vault.key-vault-whoami-api.id
  name         = "Config-DatabaseUsername"
  value        = var.database-administrator-username
  content_type = "The username used for connecting to the SQL Server"
}

resource "azurerm_mssql_server" "mssql-server-whoami-api" {
  name                = "whoami-mssql-server"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  version                       = "12.0"
  public_network_access_enabled = true

  administrator_login          = var.database-administrator-username
  administrator_login_password = var.database-administrator-password
}

resource "azurerm_mssql_database" "mssql-database-whoami-api" {
  name      = "whoami-mssql-database"
  server_id = azurerm_mssql_server.mssql-server-whoami-api.id
  tags = {
    application = var.application-name
  }
  sku_name                       = "Basic"
  storage_account_type           = "Local"
  maintenance_configuration_name = "SQL_Default"
  collation                      = "SQL_Latin1_General_CP1_CI_AS"
  geo_backup_enabled             = true
  max_size_gb                    = 2
  short_term_retention_policy {
    backup_interval_in_hours = 24
    retention_days           = 7
  }
}

resource "azurerm_mssql_firewall_rule" "sql-firewall-rule-whoami-api-allow-azure-service-access" {
  name             = "AllowAzureServiceAccess"
  server_id        = azurerm_mssql_server.mssql-server-whoami-api.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_storage_account" "storage-account-whoami-api" {
  name                = "whoamistorage"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  access_tier                     = "Hot"
  account_kind                    = "StorageV2"
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  https_traffic_only_enabled      = true
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "storage-container-whoami-api-functions" {
  name               = "functions"
  storage_account_id = azurerm_storage_account.storage-account-whoami-api.id
}

resource "azurerm_service_plan" "service-plan-whoami-api" {
  name                = "whoami-service-plan"
  location            = "ukwest" # Moved to ukwest due to SKU quota / availability limits in uksouth
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  os_type                = "Linux"
  sku_name               = "B1"
  worker_count           = 1
  zone_balancing_enabled = false
}

resource "azurerm_linux_web_app" "linux-web-app-whoami-api" {
  name                = "whoami-linux-web-app"
  location            = "ukwest" # Moved to ukwest due to SKU quota / availability limits in uksouth
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  service_plan_id               = azurerm_service_plan.service-plan-whoami-api.id
  https_only                    = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "DatabaseName"       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-name.versionless_id})"
    "DatabaseServerName" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-server-name.versionless_id})"
    "DatabaseUsername"   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-username.versionless_id})"
    "DatabasePassword"   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-password.versionless_id})"
  }

  site_config {
    worker_count = 1
    always_on    = false
    application_stack {
      dotnet_version = "10.0"
    }
  }
}

resource "azurerm_service_plan" "service-plan-whoami-api-functions" {
  name                = "whoami-functions-service-plan"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  os_type                      = "Linux"
  sku_name                     = "FC1"
  zone_balancing_enabled       = false
  worker_count                 = 1
  maximum_elastic_worker_count = 1
}

resource "azurerm_function_app_flex_consumption" "function-app-flex-consumption-whoami-api" {
  name                = "whoami-functions-app"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.resource-group-whoami-api.name
  tags = {
    application = var.application-name
  }
  enabled                       = true
  https_only                    = true
  runtime_name                  = "python"
  runtime_version               = "3.13"
  instance_memory_in_mb         = 512
  maximum_instance_count        = 100
  public_network_access_enabled = true
  service_plan_id               = azurerm_service_plan.service-plan-whoami-api-functions.id
  storage_container_type        = "blobContainer"
  storage_authentication_type   = "StorageAccountConnectionString"
  storage_container_endpoint    = "${azurerm_storage_account.storage-account-whoami-api.primary_blob_endpoint}${azurerm_storage_container.storage-container-whoami-api-functions.name}"
  storage_access_key            = azurerm_storage_account.storage-account-whoami-api.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "DatabaseName"       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-name.versionless_id})"
    "DatabaseServerName" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-server-name.versionless_id})"
    "DatabaseUsername"   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-username.versionless_id})"
    "DatabasePassword"   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-database-password.versionless_id})"
    "GitHubUsername"     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.key-vault-secret-whoami-api-github-username.versionless_id})"
  }

  site_config {
    worker_count = 1
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }
}