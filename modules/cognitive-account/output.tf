output "cognitive_account_id" {
  description = "ID of the created Azure Cognitive Services Account"
  value       = azurerm_cognitive_account.cognitive_account.id
}

output "cognitive_account_key_vault_key_id" {
  description = "ID of the created Azure Cognitive Services Key Vault Key"
  value = azurerm_key_vault_key.cognitive_account_key_vault_key.id
}