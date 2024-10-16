locals {
  key_vault_key = var.cognitive_account_key_vault_key
}

resource "azurerm_key_vault_key" "cognitive_account_key_vault_key" {
  name         = local.key_vault_key.key_name
  key_vault_id = local.key_vault_key.key_vault_id
  key_type     = local.key_vault_key.key_type
  key_size     = local.key_vault_key.key_size
  key_opts     = local.key_vault_key.key_opts
}