variable "cognitive_accounts" {
  type = map(object({
    name               = string
    resource_group_key = string
    tags = optional(map(string))

    kind     = string
    sku_name = string
    local_auth_enabled = optional(bool, true)
    public_network_access_enabled = optional(bool, false)   #Default value is true
    outbound_network_access_restricted = optional(bool, false)
    custom_question_answering_search_service_id = optional(string)
    custom_question_answering_search_service_key = optional(string)
    qna_runtime_endpoint = optional(string)
    metrics_advisor_aad_client_id = optional(string)
    metrics_advisor_aad_tenant_id = optional(string)
    metrics_advisor_website_name = optional(string)
    custom_subdomain_name = optional(string)
    fqdns = optional(list(string))

    cognitive_deployments = optional(map(object({
      name = string
      model = object({
        name    = string
        format  = string
        version = string
      })
      scale = object({
        type = string
      })
    })))

    storage = optional(object({
      storage_account_key = string
      identity_client_id = optional(string)
    }))

    cognitive_account_key_vault_key = optional(object({
        key_vault = string
        key_name  = string
        key_type  = string
        key_opts  = list(string)
        key_size  = number
    }))

    identity = object({
      type = string
      identity_key = optional(string)
    })

    network_acls = object({
      default_action = string
      ip_rules = optional(list(string), [])

      virtual_network_rules = optional(set(object({
        subnet_name = string
        ignore_missing_vnet_service_endpoint = optional(bool, false)
      })))
    })

    user_role_assignments = optional(list(object({
      role_definition_name = string
      principal_id         = string
    })))

    private_endpoint = optional(map(object({
      subnet_name = string
      private_service_connection = object({
        is_manual_connection = optional(bool, false)
        private_connection_resource_alias = optional(string)
        subresource_names = optional(string)
        request_message = optional(string)
      })
      private_dns_zone_group = object({
        dns_zone_name = string
        dns_zone_rgp  = string
      })
    })))

    diagnostic_settings = optional(map(object({
      name = optional(string, "DEFAULT-DIAGNOSTICS")
      log_analytics_workspace_id = string
      enabled_log = optional(map(object({
        category = string
        retention_policy = object({
          enabled = bool
          days    = number
        })
      })))
      metric = optional(map(object({
        category = string
        retention_policy = object({
          enabled = bool
          days    = number
        })
      })))
    })))

  }))

  default = {}
}

locals {
  cognitive_accounts = {
    for cognitive_key, cognitive_value in var.cognitive_accounts : cognitive_key => {

      name                                         = cognitive_value.name
      resource_group_name                          = module.resource_groups[cognitive_value.resource_group_key].outputs.name
      location                                     = local.location
      tags                                         = merge(cognitive_value.tags, local.resource_tags)
      kind                                         = cognitive_value.kind
      sku_name                                     = cognitive_value.sku_name
      local_auth_enabled                           = cognitive_value.local_auth_enabled
      public_network_access_enabled                = cognitive_value.public_network_access_enabled
      outbound_network_access_restricted           = cognitive_value.outbound_network_access_restricted
      custom_question_answering_search_service_id  = cognitive_value.custom_question_answering_search_service_id
      custom_question_answering_search_service_key = cognitive_value.custom_question_answering_search_service_key
      qna_runtime_endpoint                         = cognitive_value.qna_runtime_endpoint
      custom_subdomain_name                        = cognitive_value.custom_subdomain_name
      fqdns                                        = cognitive_value.fqdns
      metrics_advisor_aad_client_id                = cognitive_value.metrics_advisor_aad_client_id
      metrics_advisor_aad_tenant_id                = cognitive_value.metrics_advisor_aad_tenant_id
      metrics_advisor_website_name                 = cognitive_value.metrics_advisor_website_name

      cognitive_account_key_vault_key = try(length(cognitive_value.customer_managed_key) > 0, false) ? {
        key_name = cognitive_value.customer_managed_key.key_name
        key_vault_id = module.keyvault[cognitive_value.customer_managed_key.key_vault].outputs.id
        key_type = cognitive_value.customer_managed_key.key_type
        key_size = cognitive_value.customer_managed_key.key_size
        key_opts = cognitive_value.customer_managed_key.key_opts
      } : null

      customer_managed_key = {
        key_vault_key_id   = module.cognitive_accounts.azurerm_key_vault_key.cognitive_account_key_vault_key.id
        identity_client_id = lower(cognitive_value.identity.type) == "userassigned" && module.user_managed_identity != {} ? [module.user_managed_identity[cognitive_value.identity.identity_key].outputs.id] : []
      }


      identity = try(length(cognitive_value.identity) > 0, false) ? {
        type         = cognitive_value.identity.type
        identity_ids = lower(cognitive_value.identity.type) == "userassigned" && module.user_managed_identity != {} ? [module.user_managed_identity[cognitive_value.identity.identity_key].outputs.id] : []
      } : null

      network_acls = try(length(cognitive_value.network_acls) > 0, false) ? {
        default_action = cognitive_value.network_acls.default_action
        ip_rules = concat(cognitive_value.network_acls.ip_rules, local.org_public_ip_ranges)

        virtual_network_rules = try(length(cognitive_value.network_acls.virtual_network_rules) > 0, false) ? [
          for vnet_rule in cognitive_value.network_acls.virtual_network_rules :
          {
            subnet_id                            = data.azurerm_subnet.subnets[vnet_rule.subnet_name].id
            ignore_missing_vnet_service_endpoint = vnet_rule.ignore_missing_vnet_service_endpoint
          }
        ] : null

      } : null

      cognitive_deployments = try(length(cognitive_value.cognitive_deployments) > 0, false) ? {
        for cd_key, cd_value in cognitive_value.cognitive_deployments :
          cd_key => {
            name  = cd_value.name
            model = {
              name = cd_value.model.name
              format = cd_value.model.format
              version = cd_value.model.version
            }
            scale = {
              type = cd_value.scale.type
            }
          }
      } : {}

      ###################
      # ROLE ASSIGNMENT #
      ###################
      user_role_assignments = try(length(cognitive_value.user_role_assignments) > 0, false) ? {
        for ra_key, ra_value in cognitive_value.user_role_assignments :
        "${ra_value.principal_id}/${ra_value.role_definition_name}" => {
          role_definition_name = ra_value.role_definition_name
          principal_id         = ra_value.principal_id
        }
      } : {}

      ####################
      # PRIVATE ENDPOINT #
      ####################
      private_endpoint = try(length(cognitive_value.private_endpoint) > 0, false) ? {
        for pe_key, pe_value in cognitive_value.private_endpoint : pe_key => {
          subnet_id = data.azurerm_subnet.subnets[pe_value.subnet_name].id
          private_service_connection = {
            is_manual_connection              = pe_value.private_service_connection.is_manual_connection
            private_connection_resource_alias = pe_value.private_service_connection.private_connection_resource_alias
            subresource_names                 = [pe_value.private_service_connection.subresource_names]
            request_message                   = pe_value.private_service_connection.request_message
          }
          private_dns_zone_group = {
            dns_zone_name = pe_value.private_dns_zone_group.dns_zone_name
            dns_zone_rgp  = pe_value.private_dns_zone_group.dns_zone_rgp
          }
        }
      } : {}

      #######################
      # DIAGNOSTIC SETTINGS #
      #######################
      diagnostic_settings = try(var.global_config.destination_details_diagnostic_settings.enable_diagnostics && var.global_config.destination_details_diagnostic_settings.enable_default_diagnostics, false) ? {
        for key, value in var.default_diagnostic_settings_cognitive_account : "${cognitive_value.name}/DEFAULT-DIAGNOSTICS" => {
          name                       = "DEFAULT-DIAGNOSTICS"
          log_analytics_workspace_id = try(local.law_id, null)
          enabled_log                = try(value.enabled_log, null)
          metric                     = try(value.metric, null)
        }
      } : try(var.global_config.destination_details_diagnostic_settings.enable_diagnostics, false) ? {
        "${cognitive_value.name}/${cognitive_value.diagnostic_settings.name}" = {
          name                       = cognitive_value.diagnostic_settings.name
          log_analytics_workspace_id = try(local.law_id, null)
          enabled_log                = try(cognitive_value.diagnostic_settings.enabled_log, null)
          metric                     = try(cognitive_value.diagnostic_settings.metric, null)
        }
      } : {}

    }
  }
}

module "cognitive_accounts" {
  for_each                        = local.cognitive_accounts
  source                          = "./modules/cognitive-account"
  cognitive_account               = each.value
  cognitive_account_key_vault_key = each.value.cognitive_account_key_vault_key

  providers = {
      azurerm.src = azurerm.current-sub
      azurerm.dst = azurerm.hub-sub
  }
}