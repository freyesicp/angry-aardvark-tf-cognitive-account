resource "azurerm_key_vault_secret" "primary_access_key" {
  for_each     = local.cognitive_account
  name         = upper(replace(format("%s-primary-access-key", each.value.name), "_", "-"))
  value        = azurerm_cognitive_account.cognitive_account[each.key].primary_access_key
  key_vault_id = local.cognitive_account.key_vault_id
}

resource "azurerm_key_vault_secret" "secondary_access_key" {
  for_each     = local.cognitive_account
  name         = upper(replace(format("%s-secondary-access-key", each.value.name), "_", "-"))
  value        = azurerm_cognitive_account.cognitive_account[each.key].secondary_access_key
  key_vault_id = local.cognitive_account.key_vault_id
}

resource "azurerm_key_vault_secret" "endpoint" {
  for_each     = local.cognitive_account
  name         = upper(replace(format("%s-endpoint", each.value.name), "_", "-"))
  value        = azurerm_cognitive_account.cognitive_account[each.key].endpoint
  key_vault_id = local.cognitive_account.key_vault_id
}