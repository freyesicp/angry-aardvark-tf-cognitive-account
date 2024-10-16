cognitive_accounts = {
  openai_01 = {
    name               = "openai_01"
    resource_group_key = "rg_2"
    tags = {}

    kind     = "OpenAI"
    sku_name = "S0"

    local_auth_enabled = false

    # Key Vaults
    cognitive_account_key_vault_key = {
      key_vault = "ca_keyvault_01"
      key_name  = "openai-managed-key"
      key_type  = "RSA"
      key_opts  = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      key_size  = 2048
    }

    # Cognitive Deployments
    cognitive_deployments = {
      cd_1 = {
        name = "cd_1"

        model = {
          name = "gpt-4o-mini"
          format = "OpenAI"
          version = "2024-07-18"
        }
        scale = {
          type = "Standard"
        }
      }
    }

    # Identity
    identity = {
      type         = "UserAssigned"
      identity_key = "ca_umi_1"
    }

    # Network Information
    custom_subdomain_name     = "openai_custom_subdomain"
    network_acls = {
      default_action          = "Deny"
      bypass                  = ["Metrics","Logging","AzureServices"]

      virtual_network_rules = [
        {
          subnet_name = "existing_subnet_name"
        }
      ]
    }

    private_endpoint = {
      pe_1 = {
        subnet_name = "existing_subnet_name"
        private_service_connection = {
          is_manual_connection = false
          subresource_names    = "account"
        }
        private_dns_zone_group = {
          dns_zone_name = "privatelink.vaultcore.azure.net"
          dns_zone_rgp  = "existing-dns-zone-1"
        }
      }
    }

    # User ACL
    user_role_assignments = [
      {
        role_definition_name = "Contributor"
        principal_id         = "2222222"
      }
    ]
  }

}