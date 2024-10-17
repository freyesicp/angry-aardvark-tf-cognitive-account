resource "azurerm_key_vault_key" "cognitive_account_key_vault_key" {
  name         = local.cognitive_account.cognitive_account_key_vault_key.key_name
  key_vault_id = local.cognitive_account.cognitive_account_key_vault_key.key_vault_id
  key_type     = local.cognitive_account.cognitive_account_key_vault_key.key_type
  key_size     = local.cognitive_account.cognitive_account_key_vault_key.key_size
  key_opts     = local.cognitive_account.cognitive_account_key_vault_key.key_opts
}