module "cognitive_role_assignment" {
  for_each   = local.cognitive_account.user_role_assignments
  source     = "../role-assignments"
  scope      = azurerm_cognitive_account.cognitive_account.id
  settings   = each.value
  depends_on = [azurerm_cognitive_account.cognitive_account]
}

