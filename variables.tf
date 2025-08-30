variable "subscription_id" {
  type        = string
  description = "(Optional) The Id of the Subscription in which the Virtual Network should be created."
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name the Resource Group in which to create the Virtual Network."
}

variable "location" {
  type        = string
  description = "(Optional) The location in which to create the Virtual Network. Defaults to `UKSouth`."
  default     = "uksouth"
}

variable "name" {
  type        = string
  description = "(Required) The name of the Virtual Network to create."
}

variable "address_space" {
  type        = list(string)
  description = "(Optional) The address space(s) used by the Virtual Network. Exactly one of `address_space` or `ip_address_pool` must be specified."
  default     = null
}

variable "ddos_protection_plan" {
  type = object({
    id     = string
    enable = optional(bool, true)
  })
  description = <<-DESC
    (Optional) Enables a DDoS Protection Plan on the Virtual Network.
    `id`: (Required) The Id of the DDoS Protection Plan.
    `enable`: (Optional) Enables or disables the Protection Plan. Defaults to `true`.
  DESC
  default     = null
}

variable "dns_servers" {
  type        = list(string)
  description = "(Optional) List of IP addresses of DNS servers."
  default     = []
}

variable "edge_zone" {
  type        = string
  description = "(Optional) The Edge Zone within the Azure Region where this Virtual Network should exist."
  default     = null
}

variable "encryption" {
  type = object({
    enforcement = optional(string, "AllowUnencrypted")
  })
  description = <<-DESC
    (Optional) Specifies encryption settings for the Virtual Network.
    `enforcement`: (Optional) Specifies if the Virtual Network allows unencrypted VMs. Possible values are `AllowUnencrypted` and `DropUnencrypted`. Defaults to `AllowUnencrypted`.
  DESC
  default     = {}
}

variable "flow_timeout_in_minutes" {
  type        = number
  description = "(Optional) The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes."
  default     = null
}

variable "ip_address_pool" {
  type = object({
    id                     = string
    number_of_ip_addresses = string
  })
  description = <<-DESC
    (Optional) Specifies a Network Manager IP Address Management (IPAM) Pool. Exactly one of `address_space` or `ip_address_pool` must be specified.
    `id`: (Required) The Id of the IPAM Pool.
    `number_of_ip_addresses`: (Required) The number of IP addresses allocated to the VIrtual Network. Must be a positive number as a string.
  DESC
  default     = null
}

variable "peerings" {
  type = list(object({
    name = optional(string, null)

    remote_virtual_network = object({
      id                  = optional(string, null)
      name                = optional(string, null)
      resource_group_name = optional(string, null)
      subscription_id     = optional(string, null)
    })

    source_to_remote_config = optional(object({
      allow_forwarded_traffic      = optional(bool, false)
      allow_gateway_transit        = optional(bool, false)
      allow_virtual_network_access = optional(bool, false)
      use_remote_gateways          = optional(bool, false)
      triggers                     = optional(map(string), null)
    }), {})

    remote_to_source_config = optional(object({
      allow_forwarded_traffic      = optional(bool, false)
      allow_gateway_transit        = optional(bool, false)
      allow_virtual_network_access = optional(bool, false)
      use_remote_gateways          = optional(bool, false)
      triggers                     = optional(map(string), null)
    }), {})
  }))
  description = <<-DESC
    (Optional) A list of remote Virtual Networks to which this Virtual Network should be peered.
    Peerings will be created in both directions, to and from the remote network.
    The peering configurations (source-to-remote and remote-to-source) can be defined separately.

    `name`: (Optional) The name of the peering to create.
    `remote_virtual_network`: (Required) The details of the remote network to peer to.
      `id`: (Optional) The Id of the remote virtual network. Either `id` or `name`, `resource_group_name` and `subscription_id` must be provided.
      `name`: (Optional) The Name of the remote virtual network. Must be provided if `id` is not.
      `resource_group_name`: (Optional) The Resource Group to which the virtual network belongs. Must be provided if `id` is not.
      `subscription_id`: (Optional) The Id of the subsciption in which the virtual network exists. Allows for cross-subscription peerings. Must be provided if `id` is not.
    `source_to_remote_config`: (Optional) The configuration of the outbound peering.
      `allow_forwarded_traffic`: (Optional) Specifies if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to `false`.
      `allow_gateway_transit`: (Optional) Specifies if gateway links can be used between the remote virtual network and the local one. Defaults to `false`.
      `allow_virtual_network_access`: (Optional) Specifies if VMs in the remote virtual network can access VMs in the local one. Defaults to `false`.
      `use_remote_gateways`: (Optional) Specifies if remote gateways can be used on the local virtual network. Only one of the source or remote peerring can be set to `true`. Defaults to `false`.
    `remote_to_source_config`: The configuration of the inbound peering.
      `allow_forwarded_traffic`: (Optional) Specifies if forwarded traffic from VMs in its remote virtual network is allowed. Defaults to `false`.
      `allow_gateway_transit`: (Optional) Specifies if gateway links can be used between its remote virtual network and the local one. Defaults to `false`.
      `allow_virtual_network_access`: (Optional) Specifies if VMs in its remote virtual network can access VMs in the local one. Defaults to `false`.
      `use_remote_gateways`: (Optional) Specifies if remote gateways can be used on the local virtual network. Only one of the source or remote peerring can be set to `true`. Defaults to `false`.
  DESC
  default     = []
}

variable "private_endpoint_vnet_policies" {
  type        = string
  description = "(Optional) Sets the Private Endpoint Vnet Policies. Can be `Basic` or `Disabled`. Defaults to `Disabled`"
  default     = "Disabled"
}

variable "subnets" {
  type = list(object({
    name             = string
    address_prefixes = optional(list(string), null)

    default_outbound_access_enabled = optional(bool, true)

    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), null)
      })
    })), [])

    ip_address_pool = optional(object({
      id                     = string
      number_of_ip_addresses = string
    }), null)

    network_security_group = optional(object({
      name = string
      rules = optional(list(object({
        name                         = string
        priority                     = number
        direction                    = string
        access                       = string
        protocol                     = string
        description                  = optional(string, null)
        source_address_prefix        = optional(string, null)
        source_address_prefixes      = optional(list(string), null)
        source_port_range            = optional(string, null)
        source_port_ranges           = optional(list(string), null)
        destination_address_prefix   = optional(string, null)
        destination_address_prefixes = optional(list(string), null)
        destination_port_range       = optional(string, null)
        destination_port_ranges      = optional(list(string), null)
      })), [])
    }), null)

    network_security_group_id = optional(string, null)

    private_endpoint_network_policies             = optional(string, "Disabled")
    private_link_service_network_policies_enabled = optional(bool, true)

    route_table = optional(object({
      name                          = string
      bgp_route_propagation_enabled = optional(bool, true)

      routes = optional(list(object({
        name                   = string
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = optional(string, null)
      })), [])
    }), null)

    route_table_id = optional(string, null)

    service_endpoints           = optional(list(string), [])
    service_endpoint_policy_ids = optional(list(string), [])
  }))
  description = <<-DESC
    The details of any required Subnets.
    `name: (Required) The name of the Subnet.
    `address_prefixes`: (Optional) The subnet's address prefixes in CIDR format.
    `default_outbound_access_enabled`: (Optional) Enables default outbound internet access from the subnet.
    
    `delegations`: (Optional) List of objects defining delegations to Azure services to be specified.
      `name`: (Required) The name for the delegation.
      `service_delegation`: (Required) The specification of the service delegations.
        `name`: (Required) The name of the service to delegate to.
        `actions`: (Optional) A list of service-specific actions to delegate.
    
    `ip_address_pool`: (Optional) Specifies a Network Manager IP Address Management (IPAM) Pool. Exactly one of `address_space` or `ip_address_pool` must be specified.
      `id`: (Required) The Id of the IPAM Pool.
      `number_of_ip_addresses`: (Required) The number of IP addresses allocated to the VIrtual Network. Must be a positive number as a string.

    `network_security_group`: (Optional) Specifies a Network Security Group to create and associate with the Subnet.
      `name`: (Required) The name of the Network Security Group.
      `rules`: (Optional) Allows the specification of Network Security Rules within the Network Security Group.
        `name`: (Required) The name of the Rule.
        `priority`: (Required) Number specifying the priority of the rule.
        `direction`: (Required) Specifies the traffic direction on which the rule will be applied. Can be `Inbound` or `Outbound`.
        `access`: (Required) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
        `protocol`: (Required) The protocol that the rule applies to. Can be `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah` or `*`.
        `description`: (Optional) A description of the rule.
        `source_address_prefix`: (Optional) The IP range or tag to which the rule applies. Required if `source_address_prefixes` not supplied`.
        `source_address_prefixes`: (Optional): List if IP ranges. Tags not supported. Required if `source_address_prefix` not supplied`.
        `source_port_range`: (Optional) Source Port or range. Required if `source_port_ranges` not supplied`.
        `source_port_ranges`: (Optional) List of source Ports or ranges. Required if `source_port_range` not supplied`.
        `destination_address_prefix`: (Optional) The IP range or tag to which the rule applies. Required if `destination_address_prefixes` not supplied`.
        `destination_address_prefixes`: (Optional): List if IP ranges. Tags not supported. Required if `destination_port_range` not supplied`.
        `destination_port_range`: (Optional) Destination Port or range. Required if `destination_port_ranges` not supplied`.
        `destination_port_ranges`: (Optional) List of destination Ports or ranges. Required if `destination_port_range` not supplied`.
    `network_security_group_id`: (Optional) The Id of an existing Network Security Group to associate with the Subnet.

    `private_endpoint_network_policies`: (Optional) Enable or Disable network policies for the private endpoint on the Subnet. Possible values are `Disabled`, `Enabled`, `NetworkSecurityGroupEnabled` and `RouteTableEnabled`. Defaults to `Disabled`.
    `private_link_service_network_policies_enabled`: (Optional) Enable or Disable network policies for the private link service on the Subnet. Defaults to `true`.

    `route_table`: (Optional) Specifies a Route Table to create and associate with the Subnet.
      `name`: (Required) The name of the Route Table.
      `bgp_route_propagation_enabled`: (Optional) Specifies propagation of routes learned by BGP on thr Route Table. Defaults to `true`.
      `routes`: (Optional) Allows the specification of a list of Routes within the Route Table.
        `name`: (Required) The name of the Route.
        `address_prefix`: (Required) The destination to which the route applies.
        `next_hop_type`: (Required) The type of Azure hop the packet should be sent to. Can be `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` or `None`.
        `next_hop_in_ip_address`: (Optional) The IP Address that packets should be sent to. Only allowed when `next_hop_type` is `VirtualAppliance`.
    `route_table_id`: (Optional) The Id of an existing Route Table to associate with the Subnet.

    `service_endpoints`: (Optional) A list of Service Endpoints to associate with the Subnet.
    `service_endpoint_policy_ids`: (Optional) A list of Service Endpoint Ids to associate with the Subnet.
  DESC
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "(Optional) The list of tags to apply to the resources"
  default     = {}
}
