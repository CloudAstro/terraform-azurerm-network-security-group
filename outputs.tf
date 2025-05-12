output "nsg" {
  value       = azurerm_network_security_group.nsg
  description = <<DESCRIPTION
  * `name` - The name of the Network Security Group.
  * `resource_group_name` - The name of the resource group in which the NSG is created.
  * `location` - The Azure location where the NSG exists.
  * `id` - The resource ID of the NSG.
  * `security_rule` - A list of security rules defined in this NSG.
  * `tags` - A mapping of tags assigned to the NSG.

  Example output:
  ```
  output "name" {
    value = module.module_name.nsg.name
  }
  ```
  DESCRIPTION
}
