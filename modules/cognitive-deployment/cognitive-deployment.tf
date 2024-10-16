locals {
  cognitive_deployment = var.cognitive_deployment
}

resource "azurerm_cognitive_deployment" "cognitive_deployment" {
  cognitive_account_id = var.cognitive_account_id
  name                 = local.cognitive_deployment.name

  model {
      name = local.cognitive_deployment.model.name
      format = local.cognitive_deployment.model.format
      version = local.cognitive_deployment.model.version
  }

  scale {
    type = local.cognitive_deployment.scale.type
  }
}