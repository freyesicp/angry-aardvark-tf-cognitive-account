module "cognitive_account_cognitive_deployment" {
  for_each              = local.cognitive_account.cognitive_deployments
  source                = "../cognitive-deployment"
  cognitive_account_id  = azurerm_cognitive_account.cognitive_account.id
  cognitive_deployment  = each.value
  depends_on            = [azurerm_cognitive_account.cognitive_account]
}
