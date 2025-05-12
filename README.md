<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# Azure Network Security Group (NSG) Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/cloudastro/network-security-group/azurerm/)

This Terraform module provisions and manages Azure Network Security Groups (NSGs), which act as virtual firewalls to control inbound and outbound traffic for Azure resources. It supports defining detailed security rules and associating NSGs with subnets or network interfaces.

## Features

- **Flexible NSG Creation**: Create one or more Network Security Groups in a specified resource group and location.
- **Custom Security Rules**: Define granular inbound and outbound rules with support for direction, access control, protocols, and address/port filtering.
- **Associations**: Easily bind NSGs to subnets or network interfaces to enforce network access policies.
- **Built-In Tag Support**: Use Azure tags like `Internet`, `VirtualNetwork`, and others for simplified rule configuration.
- **Diagnostics Integration**: Optionally configure diagnostic settings to send NSG flow logs to a Storage Account, Event Hub, or Log Analytics Workspace.

## Example Usage

This example demonstrates how to deploy an NSG with custom security rules and associate it with a subnet or network interface.

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-nsg-example"
  location = "germanywestcentral"
}

module "vnet" {
  source              = "CloudAstro/virtual-network/azurerm"
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "snet" {
  source               = "CloudAstro/subnet/azurerm"
  name                 = "snet-example"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "network_security_group" {
  source              = "../.."
  name                = "nsg1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = module.snet.subnet.id

  security_rules = [
    {
      name                       = "Allow-HTTPS-In"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "192.168.1.0/24"
      destination_address_prefix = "*"
    },
    {
      name                       = "Deny-All-In"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    environment = "Production"
    owner       = "example-team"
  }
}
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.nsg_diag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.security_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet_network_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | * `location` - (Required) The Azure region where the resource will be created.<br/><br/>  Example Input:<pre>location = "East US"</pre> | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | * `name` - (Required) Specifies the name of the Network Security Group (NSG).<br/><br/>  Example Input:<pre>name = "my-security-group"</pre> | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | * `resource_group_name` - (Required) Specifies the name of the Resource Group within which the Network Security Group exists.<br/><br/>  Example Input:<pre>resource_group_name = "my-resource-group"</pre> | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | * `subnet_id` - (Optional) The ID of the subnet to associate with the Network Security Group.<br/><br/>  Example Input:<pre>subnet_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/my-resource-group/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"</pre> | `string` | n/a | yes |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | * `monitor_diagnostic_setting` - (Optional) The `monitor_diagnostic_setting` block resource as defined below.<br/><br/>    * `name` - (Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created.<br/><br/>    -> **Note:** If the name is set to 'service' it will not be possible to fully delete the diagnostic setting. This is due to legacy API support.<br/>    * `target_resource_id` - (Required) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created.<br/>    * `eventhub_name` - (Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent.<br/><br/>    -> **Note:** If this isn't specified then the default Event Hub will be used.<br/>    * `eventhub_authorization_rule_id` - (Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data.<br/><br/>    -> **Note:** This can be sourced from [the `azurerm_eventhub_namespace_authorization_rule` resource](eventhub\_namespace\_authorization\_rule.html) and is different from [a `azurerm_eventhub_authorization_rule` resource](eventhub\_authorization\_rule.html).<br/><br/>    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>    * `log_analytics_workspace_id` - (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.<br/><br/>    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>    * `storage_account_id` - (Optional) The ID of the Storage Account where logs should be sent.<br/><br/>    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>    * `log_analytics_destination_type` - (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to `Dedicated`, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.<br/><br/>    -> **Note:** This setting will only have an effect if a `log_analytics_workspace_id` is provided. For some target resource type (e.g., Key Vault), this field is unconfigurable. Please see [resource types](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types) for services that use each method. Please [see the documentation](https://docs.microsoft.com/azure/azure-monitor/platform/diagnostic-logs-stream-log-store#azure-diagnostics-vs-resource-specific) for details on the differences between destination types.<br/>    * `partner_solution_id` - (Optional) The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, [click to learn more about partner integration](https://learn.microsoft.com/en-us/azure/partner-solutions/overview).<br/><br/>    -> **Note:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>    * `enabled_log` - (Optional) One or more `enabled_log` blocks as defined below.<br/><br/>    -> **Note:** At least one `enabled_log` or `metric` block must be specified. At least one type of Log or Metric must be enabled.<br/>    * `metric` - (Optional) One or more `metric` blocks as defined below.<br/><br/>    -> **Note:** At least one `enabled_log` or `metric` block must be specified.<br/><br/>  An `enabled_log` block supports the following:<br/>    * `category` - (Optional) The name of a Diagnostic Log Category for this Resource.<br/><br/>    -> **Note:** The Log Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor\_diagnostic\_categories.html) or [list of service specific schemas](https://docs.microsoft.com/azure/azure-monitor/platform/resource-logs-schema#service-specific-schemas) to identify which categories are available for a given Resource.<br/>    * `category_group` - (Optional) The name of a Diagnostic Log Category Group for this Resource.<br/><br/>    -> **Note:** Not all resources have category groups available.<br/><br/>    -> **Note:** Exactly one of `category` or `category_group` must be specified.<br/><br/>  The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>    * `create` - (Defaults to 30 minutes) Used when creating the Diagnostics Setting.<br/>    * `update` - (Defaults to 30 minutes) Used when updating the Diagnostics Setting.<br/>    * `read` - (Defaults to 5 minutes) Used when retrieving the Diagnostics Setting.<br/>    * `delete` - (Defaults to 60 minutes) Used when deleting the Diagnostics Setting.<br/><br/>    Example Input:<pre>diagnostic_settings = {<br/>      name                           = "nsg-diagnostic-setting"<br/>      target_resource_id             = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/networkSecurityGroups/<nsg-name>"<br/>      eventhub_name                  = null<br/>      eventhub_authorization_rule_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.EventHub/namespaces/<eventhub-namespace>/authorizationRules/<auth-rule-name>"<br/>      log_analytics_workspace_id     = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"<br/>      storage_account_id             = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>"<br/>      log_analytics_destination_type = "AzureDiagnostics"<br/>      partner_solution_id            = null<br/>        enabled_log = [<br/>          {<br/>            category_group = "allLogs"<br/>          }<br/>        ]<br/>      }<br/>    }</pre> | <pre>map(object({<br/>    name                           = string<br/>    target_resource_id             = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    partner_solution_id            = optional(string)<br/>    enabled_log = optional(set(object({<br/>      category       = optional(string)<br/>      category_group = optional(string)<br/>    })))<br/>    timeouts = optional(object({<br/>      create = optional(string, "30")<br/>      update = optional(string, "30")<br/>      read   = optional(string, "5")<br/>      delete = optional(string, "60")<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | The following arguments are supported:<br/><br/>  * `name` - (Required) The name of the security rule. This needs to be unique across all Rules in the Network Security Group. Changing this forces a new resource to be created.<br/>  * `resource_group_name` - (Required) The name of the resource group in which to create the Network Security Rule. Changing this forces a new resource to be created.<br/>  * `network_security_group_name` - (Required) The name of the Network Security Group that we want to attach the rule to. Changing this forces a new resource to be created.<br/>  * `description` - (Optional) A description for this rule. Restricted to 140 characters.<br/>  * `protocol` - (Required) Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah` or `*` (which matches all).<br/>  * `source_port_range` - (Optional) Source Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `source_port_ranges` is not specified.<br/>  * `source_port_ranges` - (Optional) List of source ports or port ranges. This is required if `source_port_range` is not specified.<br/>  * `destination_port_range` - (Optional) Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `destination_port_ranges` is not specified.<br/>  * `destination_port_ranges` - (Optional) List of destination ports or port ranges. This is required if `destination_port_range` is not specified.<br/>  * `source_address_prefix` - (Optional) CIDR or source IP range or * to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. This is required if `source_address_prefixes` is not specified.<br/>  * `source_address_prefixes` - (Optional) List of source address prefixes. Tags may not be used. This is required if `source_address_prefix` is not specified.<br/>  * `source_application_security_group_ids` - (Optional) A List of source Application Security Group IDs<br/>  * `destination_address_prefix` - (Optional) CIDR or destination IP range or * to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. Besides, it also supports all available Service Tags like ‘Sql.WestEurope‘, ‘Storage.EastUS‘, etc. You can list the available service tags with the CLI:<pre>shell az network list-service-tags --location westcentralus</pre>. For further information please see [Azure CLI - az network list-service-tags](https://docs.microsoft.com/cli/azure/network?view=azure-cli-latest#az-network-list-service-tags). This is required if `destination_address_prefixes` is not specified.<br/>  * `destination_address_prefixes` - (Optional) List of destination address prefixes. Tags may not be used. This is required if `destination_address_prefix` is not specified.<br/>  * `destination_application_security_group_ids` - (Optional) A List of destination Application Security Group IDs<br/>  * `access` - (Required) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.<br/>  * `priority` - (Required) Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.<br/>  * `direction` - (Required) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.<br/><br/>  Example Input:<pre>security_rules = [<br/>      {<br/>        name                       = "security_rules_name"<br/>        description                = "Allow All IN"<br/>        protocol                   = "\*"<br/>        source_port_range          = "\*"<br/>        destination_port_range     = "\*"<br/>        source_address_prefix      = "\*"<br/>        destination_address_prefix = "\*"<br/>        access                     = "Allow"<br/>        priority                   = 1001<br/>        direction                  = "Inbound"<br/>      }<br/>    ]</pre> | <pre>list(object({<br/>    name                                       = string<br/>    description                                = optional(string)<br/>    protocol                                   = string<br/>    source_port_range                          = optional(string)<br/>    source_port_ranges                         = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(set(string))<br/>    destination_application_security_group_ids = optional(set(string))<br/>    access                                     = string<br/>    priority                                   = number<br/>    direction                                  = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | * `tags` - (Optional) A mapping of tags to associate with the Network Security Group. Tags help categorize resources in Azure with key-value pairs for better management, organization, and cost tracking.<br/><br/>  Example Input:<pre>tags = {<br/>    "environment" = "production"<br/>    "department"  = "IT"<br/>  }</pre> | `map(string)` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>    * `create` - (Defaults to 30 minutes) Used when creating the Subnet.<br/>    * `update` - (Defaults to 30 minutes) Used when updating the Subnet.<br/>    * `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.<br/>    * `delete` - (Defaults to 30 minutes) Used when deleting the Subnet. | <pre>object({<br/>    create = optional(string, "30")<br/>    update = optional(string, "30")<br/>    read   = optional(string, "5")<br/>    delete = optional(string, "30")<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg"></a> [nsg](#output\_nsg) | * `name` - The name of the Network Security Group.<br/>  * `resource_group_name` - The name of the resource group in which the NSG is created.<br/>  * `location` - The Azure location where the NSG exists.<br/>  * `id` - The resource ID of the NSG.<br/>  * `security_rule` - A list of security rules defined in this NSG.<br/>  * `tags` - A mapping of tags assigned to the NSG.<br/><br/>  Example output:<pre>output "name" {<br/>    value = module.module_name.nsg.name<br/>  }</pre> |

## Modules

No modules.

## 🌐 Additional Information

For comprehensive guidance on Azure Network Security Groups and best practices, refer to the [Azure NSG documentation](https://learn.microsoft.com/en-us/azure/virtual-network/security-overview). This module provides flexibility in defining fine-grained security rules to control traffic to and from your Azure resources.

## 📚 Resources

- [Terraform AzureRM Provider – `azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- [Azure Network Security Groups Overview](https://learn.microsoft.com/en-us/azure/virtual-network/security-overview)
- [Azure Network Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)

## ⚠️ Notes  

- Carefully plan and review your NSG rules to avoid unintentionally blocking required traffic.
- Follow Azure security and compliance guidelines to ensure a robust and secure network design.
- Always validate and test your Terraform plans before applying changes to production environments.

## 🧾 License  

This module is released under the **Apache 2.0 License**. See the [LICENSE](./LICENSE) file for full details.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->