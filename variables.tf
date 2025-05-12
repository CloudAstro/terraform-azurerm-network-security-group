# Network Security Group definition
variable "name" {
  type        = string
  description = <<DESCRIPTION
  * `name` - (Required) Specifies the name of the Network Security Group (NSG).

  Example Input:
  ```
  name = "my-security-group"
  ```
  DESCRIPTION
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
  * `resource_group_name` - (Required) Specifies the name of the Resource Group within which the Network Security Group exists.

  Example Input:
  ```
  resource_group_name = "my-resource-group"
  ```
  DESCRIPTION
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
  * `location` - (Required) The Azure region where the resource will be created.

  Example Input:
  ```
  location = "East US"
  ```
  DESCRIPTION
}

variable "subnet_id" {
  type        = string
  description = <<DESCRIPTION
  * `subnet_id` - (Optional) The ID of the subnet to associate with the Network Security Group.

  Example Input:
  ```
  subnet_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/my-resource-group/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
  ```
  DESCRIPTION
}

# Security Rules
variable "security_rules" {
  type = list(object({
    name                                       = string
    description                                = optional(string)
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(set(string))
    destination_application_security_group_ids = optional(set(string))
    access                                     = string
    priority                                   = number
    direction                                  = string
  }))
  default = []
  validation {
    condition     = alltrue([for rule in var.security_rules : rule.priority >= 100 && rule.priority <= 4096])
    error_message = "Each 'priority' must be between 100 and 4096."
  }
  description = <<DESCRIPTION
  The following arguments are supported:

  * `name` - (Required) The name of the security rule. This needs to be unique across all Rules in the Network Security Group. Changing this forces a new resource to be created.
  * `resource_group_name` - (Required) The name of the resource group in which to create the Network Security Rule. Changing this forces a new resource to be created.
  * `network_security_group_name` - (Required) The name of the Network Security Group that we want to attach the rule to. Changing this forces a new resource to be created.
  * `description` - (Optional) A description for this rule. Restricted to 140 characters.
  * `protocol` - (Required) Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah` or `*` (which matches all).
  * `source_port_range` - (Optional) Source Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `source_port_ranges` is not specified.
  * `source_port_ranges` - (Optional) List of source ports or port ranges. This is required if `source_port_range` is not specified.
  * `destination_port_range` - (Optional) Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `destination_port_ranges` is not specified.
  * `destination_port_ranges` - (Optional) List of destination ports or port ranges. This is required if `destination_port_range` is not specified.
  * `source_address_prefix` - (Optional) CIDR or source IP range or * to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. This is required if `source_address_prefixes` is not specified.
  * `source_address_prefixes` - (Optional) List of source address prefixes. Tags may not be used. This is required if `source_address_prefix` is not specified.
  * `source_application_security_group_ids` - (Optional) A List of source Application Security Group IDs
  * `destination_address_prefix` - (Optional) CIDR or destination IP range or * to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. Besides, it also supports all available Service Tags like ‘Sql.WestEurope‘, ‘Storage.EastUS‘, etc. You can list the available service tags with the CLI: ```shell az network list-service-tags --location westcentralus```. For further information please see [Azure CLI - az network list-service-tags](https://docs.microsoft.com/cli/azure/network?view=azure-cli-latest#az-network-list-service-tags). This is required if `destination_address_prefixes` is not specified.
  * `destination_address_prefixes` - (Optional) List of destination address prefixes. Tags may not be used. This is required if `destination_address_prefix` is not specified.
  * `destination_application_security_group_ids` - (Optional) A List of destination Application Security Group IDs
  * `access` - (Required) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
  * `priority` - (Required) Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.
  * `direction` - (Required) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.

  Example Input:
  ```
  security_rules = [
      {
        name                       = "security_rules_name"
        description                = "Allow All IN"
        protocol                   = "\*"
        source_port_range          = "\*"
        destination_port_range     = "\*"
        source_address_prefix      = "\*"
        destination_address_prefix = "\*"
        access                     = "Allow"
        priority                   = 1001
        direction                  = "Inbound"
      }
    ]
  ```
  DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  * `tags` - (Optional) A mapping of tags to associate with the Network Security Group. Tags help categorize resources in Azure with key-value pairs for better management, organization, and cost tracking.

  Example Input:
  ```
  tags = {
    "environment" = "production"
    "department"  = "IT"
  }
  ```
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string, "30")
    update = optional(string, "30")
    read   = optional(string, "5")
    delete = optional(string, "30")
  })
  default     = null
  description = <<DESCRIPTION
  The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
    * `create` - (Defaults to 30 minutes) Used when creating the Subnet.
    * `update` - (Defaults to 30 minutes) Used when updating the Subnet.
    * `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.
    * `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.
  DESCRIPTION
}

variable "diagnostic_settings" {
  type = map(object({
    name                           = string
    target_resource_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    log_analytics_destination_type = optional(string)
    partner_solution_id            = optional(string)
    enabled_log = optional(set(object({
      category       = optional(string)
      category_group = optional(string)
    })))
    timeouts = optional(object({
      create = optional(string, "30")
      update = optional(string, "30")
      read   = optional(string, "5")
      delete = optional(string, "60")
    }))
  }))
  default     = null
  description = <<DESCRIPTION
  * `monitor_diagnostic_setting` - (Optional) The `monitor_diagnostic_setting` block resource as defined below.

    * `name` - (Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created.

    -> **Note:** If the name is set to 'service' it will not be possible to fully delete the diagnostic setting. This is due to legacy API support.
    * `target_resource_id` - (Required) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created.
    * `eventhub_name` - (Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent.

    -> **Note:** If this isn't specified then the default Event Hub will be used.
    * `eventhub_authorization_rule_id` - (Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data.

    -> **Note:** This can be sourced from [the `azurerm_eventhub_namespace_authorization_rule` resource](eventhub_namespace_authorization_rule.html) and is different from [a `azurerm_eventhub_authorization_rule` resource](eventhub_authorization_rule.html).

    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
    * `log_analytics_workspace_id` - (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.

    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
    * `storage_account_id` - (Optional) The ID of the Storage Account where logs should be sent.

    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
    * `log_analytics_destination_type` - (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to `Dedicated`, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.

    -> **Note:** This setting will only have an effect if a `log_analytics_workspace_id` is provided. For some target resource type (e.g., Key Vault), this field is unconfigurable. Please see [resource types](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types) for services that use each method. Please [see the documentation](https://docs.microsoft.com/azure/azure-monitor/platform/diagnostic-logs-stream-log-store#azure-diagnostics-vs-resource-specific) for details on the differences between destination types.
    * `partner_solution_id` - (Optional) The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, [click to learn more about partner integration](https://learn.microsoft.com/en-us/azure/partner-solutions/overview).

    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
    * `enabled_log` - (Optional) One or more `enabled_log` blocks as defined below.

    -> **Note:** At least one `enabled_log` or `metric` block must be specified. At least one type of Log or Metric must be enabled.
    * `metric` - (Optional) One or more `metric` blocks as defined below.

    -> **Note:** At least one `enabled_log` or `metric` block must be specified.

  An `enabled_log` block supports the following:
    * `category` - (Optional) The name of a Diagnostic Log Category for this Resource.

    -> **Note:** The Log Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor_diagnostic_categories.html) or [list of service specific schemas](https://docs.microsoft.com/azure/azure-monitor/platform/resource-logs-schema#service-specific-schemas) to identify which categories are available for a given Resource.
    * `category_group` - (Optional) The name of a Diagnostic Log Category Group for this Resource.

    -> **Note:** Not all resources have category groups available.

    -> **Note:** Exactly one of `category` or `category_group` must be specified.

  The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
    * `create` - (Defaults to 30 minutes) Used when creating the Diagnostics Setting.
    * `update` - (Defaults to 30 minutes) Used when updating the Diagnostics Setting.
    * `read` - (Defaults to 5 minutes) Used when retrieving the Diagnostics Setting.
    * `delete` - (Defaults to 60 minutes) Used when deleting the Diagnostics Setting.

    Example Input:
    ```
    diagnostic_settings = {
      name                           = "nsg-diagnostic-setting"
      target_resource_id             = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/networkSecurityGroups/<nsg-name>"
      eventhub_name                  = null
      eventhub_authorization_rule_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.EventHub/namespaces/<eventhub-namespace>/authorizationRules/<auth-rule-name>"
      log_analytics_workspace_id     = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
      storage_account_id             = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>"
      log_analytics_destination_type = "AzureDiagnostics"
      partner_solution_id            = null
        enabled_log = [
          {
            category_group = "allLogs"
          }
        ]
      }
    }
    ```
    DESCRIPTION
}
