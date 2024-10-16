module "cognitive_account_diagnostics" {
  for_each           = local.cognitive_account.diagnostic_settings
  source             = "../diagnostic-settings"
  target_resource_id = azurerm_cognitive_account.cognitive_account.id
  settings           = each.value
  depends_on         = [azurerm_cognitive_account.cognitive_account]
}

