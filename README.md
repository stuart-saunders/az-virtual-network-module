# Azure Virtual Network Module

Terraform Module for provisioning Virtual Networks on Azure.

## Description

The module supports the creation of a Virtual Network, in addition to its dependent, child resources, allowing a resource hierarchy to be defined in an object, and using this to provision the required resources. Each Virtual Network can contain multiple peerings and subnets, each of which can contain a Network Security Group, itself containing multiple Network Security Rules. Each Subnet can also contain a Route Table, which itself can contain multiple routes. All of these can be defined within a single object, which the module will use this to provision the resources required.

Each Subnet's Network Security Group can either be defined within the subnet object such that it is provisioned at the same time, or can pre-exist and have its Id associated when the subnet is created. Each NSG's rules that can also be defined and created within the NSG object.

Route Tables can also be defined within the subnet object, or can pre-exist and be associated with a subnet by providing its Id.

When defining lists of peerings, for any supplied remote networks, peerings will be created in both directions, with the settings for each peering being able to be individually configured.

## Providers

The module provisions all of its resources using the `azurerm` provider.

## Resources

The module supports the creation of the following resources:-

- `azurerm_virtual_network`
- `azurerm_network_security_group`
- `azurerm_network_security_rule`
- `azurerm_subnet_network_security_group_association`
- `azurerm_route_table`
- `azurerm_route`
- `azurerm_subnet_route_table_association`
- `azurerm_virtual_network_dns_servers`
- `azurerm_virtual_network_peering`

## Properties
The module supports the setting of the following properties:-

- `subscription_id` (Optional)
- `resource_group_name` (Required)
- `location` (Optional) Defaults to `uksouth`.

- `name` (Required)
- `address_space` (Optional)
- `ddos_protection_plan` (Optional)
- `dns_servers` (Optional)
- `edge_zone` (Optional)
- `encryption` (Optional)
- `flow_timeout_in_minutes` (Optional)
- `ip_address_pool` (Optional)

- `peerings` (Optional)
  - `name` (Optional)

  - `remote_virtual_network` (Optional)
    - `id` (Optional)
    - `name` (Optional)
    - `resource_group_name` (Optional)
    - `subscription_id` (Optional)

  - `source_to_remote_config` (Optional)
    - `allow_forwarded_traffic` (Optional) Defaults to `false`.
    - `allow_gateway_transit` (Optional) Defaults to `false`.
    - `allow_virtual_network_access` (Optional) Defaults to `false`.
    - `use_remote_gateways` (Optional) Defaults to `false`.
    - `triggers` (Optional)

  - `remote_to_source_config` (Optional)
    - `allow_forwarded_traffic` (Optional) Defaults to `false`.
    - `allow_gateway_transit` (Optional) Defaults to `false`.
    - `allow_virtual_network_access` (Optional) Defaults to `false`.
    - `use_remote_gateways` (Optional) Defaults to `false`.
    - `triggers` (Optional)

- `private_endpoint_vnet_policies` (Optional)

- `subnets` (Optional)
  - `name` (Required)
  - `address_prefixes` (Optional)
  - `default_outbound_access_enabled` (Optional)
 
  - `delegations` (Optional)
    - `name` Required
    - `service_delegation` (Required)
      - `name` (Required)
      - `actions` (Optional)

  - `ip_address_pool` (Optional)
    - `id` (Required)
    - `number_of_ip_addresses` (Required)
  
  - `network_security_group`(Optional)
    - `name` (Required)
    - `rules` (Optional)
      - `name` (Required)
      - `priority` (Required)
      - `direction` (Required)
      - `access` (Required)
      - `protocol` (Required)
      - `source_address_prefix` (Optional)
      - `source_address_prefixes` (Optional)
      - `source_port_range` (Optional)
      - `source_port_ranges` (Optional)
      - `destination_address_prefix` (Optional)
      - `destination_address_prefixes` (Optional)
      - `destination_port_range` (Optional)
      - `destination_port_ranges` (Optional)
            
  - `network_security_group_id` (Optional)

  - `private_endpoint_network_policies` (Optional) Defaults to `Disabled`.
  - `private_link_service_network_policies_enabled` (Optional) Defaults to `true`.

  - `route_table` (Optional)
    - `name` (Required)
    - `disable_bgp_route_propagation` (Optional) Defaults to `true`.
    - `routes` (Optional)
        - `name` (Required)
        - `address_prefix` (Required)
        - `next_hop_type` (Required)
        - `next_hop_in_ip_address` (Optional)

  - `route_table_id` (Optional)

  - `service_endpoints` (Optional)
  - `service_endpoint_policy_ids` (Optional)


## Outputs
The module outputs the following values:-

- `id` The Virtual Network Id
- `name` The Virtual Network Name
- `subnets` The details of the Virtual Network's Subnets
- `peerings` The details of the Virtual Network's Peerings