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
