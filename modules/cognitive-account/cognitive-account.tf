locals {
  cognitive_account = var.cognitive_account
}

resource "azurerm_cognitive_account" "cognitive_account" {

  name                                         = local.cognitive_account.name
  location                                     = local.cognitive_account.location
  resource_group_name                          = local.cognitive_account.resource_group_name
  kind                                         = local.cognitive_account.kind
  sku_name                                     = local.cognitive_account.sku_name
  local_auth_enabled                           = local.cognitive_account.local_auth_enabled
  public_network_access_enabled                = local.cognitive_account.public_network_access_enabled
  outbound_network_access_restricted           = local.cognitive_account.outbound_network_access_restricted
  custom_question_answering_search_service_id  = local.cognitive_account.custom_question_answering_search_service_id
  custom_question_answering_search_service_key = local.cognitive_account.custom_question_answering_search_service_key
  qna_runtime_endpoint                         = local.cognitive_account.qna_runtime_endpoint
  custom_subdomain_name                        = local.cognitive_account.custom_subdomain_name
  fqdns                                        = local.cognitive_account.fqdns
  tags                                         = local.cognitive_account.tags
  metrics_advisor_aad_client_id                = local.cognitive_account.metrics_advisor_aad_client_id
  metrics_advisor_aad_tenant_id                = local.cognitive_account.metrics_advisor_aad_tenant_id
  metrics_advisor_website_name                 = local.cognitive_account.metrics_advisor_website_name

  dynamic "storage" {
    for_each = try(length(local.cognitive_account.storage), 0) > 0 ? [local.cognitive_account.storage] : []

    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
  }

  dynamic "customer_managed_key" {
    for_each = try(length(local.cognitive_account.customer_managed_key), 0) > 0 ? [local.cognitive_account.customer_managed_key] : []

    content {
      key_vault_key_id   = azurerm_key_vault_key.cognitive_account_key_vault_key.id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }

  dynamic "network_acls" {
    for_each = try(length(local.cognitive_account.network_acls), 0) > 0 ? [local.cognitive_account.network_acls] : []
    content {
      default_action = network_acls.value.default_action
      ip_rules       = network_acls.value.ip_rules
      dynamic "virtual_network_rules" {
        for_each = try(length(network_acls.value.virtual_network_rules), 0) > 0 ? network_acls.value.virtual_network_rules : []
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "identity" {
    for_each = try(length(local.cognitive_account.identity), 0) > 0 ? [local.cognitive_account.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids

    }
  }

}