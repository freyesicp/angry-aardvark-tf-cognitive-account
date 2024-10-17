data "azurerm_private_dns_zone" "dns_zone" {
  for_each = try(length(local.cognitive_account.private_endpoint), 0) > 0 ? local.cognitive_account.private_endpoint : {}

  name                = each.value.private_dns_zone_group.dns_zone_name
  resource_group_name = each.value.private_dns_zone_group.dns_zone_rgp

  provider = azurerm.dst
}


module "cognitive_account_private_endpoint" {
  for_each = try(length(local.cognitive_account.private_endpoint), 0) > 0 ? local.cognitive_account.private_endpoint : {}
  source   = "../private-endpoint"

  name                           = data.azurerm_private_dns_zone.dns_zone[each.key].name
  resource_group_name            = data.azurerm_private_dns_zone.dns_zone[each.key].resource_group_name
  private_dns_zone_ids           = [data.azurerm_private_dns_zone.dns_zone[each.key].id]
  private_connection_resource_id = azurerm_cognitive_account.cognitive_account.id
  private_endpoint               = local.cognitive_account
  settings                       = each.value
  depends_on                     = [azurerm_cognitive_account.cognitive_account]
}
