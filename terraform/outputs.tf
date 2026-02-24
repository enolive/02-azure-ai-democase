# output "resource_group_name" {
#   description = "Name of the resource group"
#   value       = azurerm_resource_group.rg.name
# }

# output "resource_group_id" {
#   description = "ID of the resource group"
#   value       = azurerm_resource_group.rg.id
# }

# # Storage Outputs
# output "storage_account_name" {
#   description = "Name of the storage account for claims"
#   value       = module.storage.storage_account_name
# }

# output "storage_account_key" {
#   description = "Primary access key for storage account"
#   value       = module.storage.primary_access_key
#   sensitive   = true
# }

# output "claims_container_name" {
#   description = "Name of the blob container for insurance claims"
#   value       = module.storage.claims_container_name
# }

# output "processed_container_name" {
#   description = "Name of the blob container for processed data"
#   value       = module.storage.processed_container_name
# }

# output "storage_connection_string" {
#   description = "Connection string for storage account"
#   value       = module.storage.primary_connection_string
#   sensitive   = true
# }

# # Document Intelligence Outputs
# output "doc_intelligence_name" {
#   description = "Name of Azure AI Document Intelligence"
#   value       = module.document_intelligence.name
# }

# output "doc_intelligence_endpoint" {
#   description = "Endpoint for Azure AI Document Intelligence"
#   value       = module.document_intelligence.endpoint
# }

# output "doc_intelligence_key" {
#   description = "Primary key for Azure AI Document Intelligence"
#   value       = module.document_intelligence.primary_access_key
#   sensitive   = true
# }

# # Search Outputs
# output "search_service_name" {
#   description = "Name of Azure AI Search service"
#   value       = module.search.name
# }

# output "search_endpoint" {
#   description = "Endpoint for Azure AI Search"
#   value       = module.search.endpoint
# }

# output "search_admin_key" {
#   description = "Admin key for Azure AI Search"
#   value       = module.search.primary_key
#   sensitive   = true
# }

# # OpenAI Outputs
# output "openai_name" {
#   description = "Name of Azure OpenAI service"
#   value       = module.openai.name
# }

# output "openai_endpoint" {
#   description = "Endpoint for Azure OpenAI"
#   value       = module.openai.endpoint
# }

# output "openai_key" {
#   description = "Primary key for Azure OpenAI"
#   value       = module.openai.primary_access_key
#   sensitive   = true
# }

# output "gpt4_deployment_name" {
#   description = "Name of GPT-4 deployment"
#   value       = module.openai.gpt4_deployment_name
# }

# output "embedding_deployment_name" {
#   description = "Name of embedding deployment"
#   value       = module.openai.embedding_deployment_name
# }

# # AI Foundry Outputs
# output "ai_hub_name" {
#   description = "Name of Azure AI Foundry Hub"
#   value       = module.ai_foundry.hub_name
# }

# output "ai_project_name" {
#   description = "Name of Azure AI Foundry Project"
#   value       = module.ai_foundry.project_name
# }

# # Monitoring Outputs
# output "key_vault_name" {
#   description = "Name of Key Vault"
#   value       = module.monitoring.key_vault_name
# }

# output "application_insights_name" {
#   description = "Name of Application Insights"
#   value       = module.monitoring.application_insights_name
# }

# output "application_insights_instrumentation_key" {
#   description = "Instrumentation key for Application Insights"
#   value       = module.monitoring.application_insights_instrumentation_key
#   sensitive   = true
# }

# output "log_analytics_workspace_name" {
#   description = "Name of Log Analytics Workspace"
#   value       = module.monitoring.log_analytics_workspace_name
# }

# # Summary output for easy reference
# output "deployment_summary" {
#   description = "Summary of deployed resources"
#   value = {
#     resource_group       = azurerm_resource_group.rg.name
#     location             = azurerm_resource_group.rg.location
#     storage_account      = module.storage.storage_account_name
#     claims_container     = module.storage.claims_container_name
#     doc_intelligence     = module.document_intelligence.name
#     search_service       = module.search.name
#     openai_service       = module.openai.name
#     ai_hub               = module.ai_foundry.hub_name
#     ai_project           = module.ai_foundry.project_name
#     key_vault            = module.monitoring.key_vault_name
#     application_insights = module.monitoring.application_insights_name
#   }
# }
