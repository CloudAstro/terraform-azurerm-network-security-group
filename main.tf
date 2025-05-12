resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_security_rule" "security_rules" {
  for_each = var.security_rules != null ? { for value in var.security_rules : value.name => value } : null

  name                                       = each.value.name
  resource_group_name                        = var.resource_group_name
  network_security_group_name                = azurerm_network_security_group.nsg.name
  description                                = each.value.description
  protocol                                   = each.value.protocol
  source_port_range                          = each.value.source_port_range
  source_port_ranges                         = each.value.source_port_ranges
  destination_port_range                     = each.value.destination_port_range
  destination_port_ranges                    = each.value.destination_port_ranges
  source_address_prefix                      = each.value.source_address_prefix
  source_address_prefixes                    = each.value.source_address_prefixes
  destination_address_prefix                 = each.value.destination_address_prefix
  destination_address_prefixes               = each.value.destination_address_prefixes
  source_application_security_group_ids      = each.value.source_application_security_group_ids
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
  access                                     = each.value.access
  priority                                   = each.value.priority
  direction                                  = each.value.direction

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = var.subnet_id
}

# monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "nsg_diag" {
  for_each = var.diagnostic_settings == null ? {} : var.diagnostic_settings

  name                           = each.value.name
  target_resource_id             = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  eventhub_name                  = each.value.eventhub_name
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  storage_account_id             = each.value.storage_account_id
  partner_solution_id            = each.value.partner_solution_id

  dynamic "enabled_log" {
    for_each = each.value.enabled_log != null ? each.value.enabled_log : []
    content {
      category       = enabled_log.value.category_group == null ? enabled_log.value.category : null
      category_group = enabled_log.value.category_group
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}
