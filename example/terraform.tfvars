#subscription_id     = "<subscription_id>"
resource_group_name = "rg-vnet-module-example1"

vnets = [
  # Virtual Network with no Subnets
  {
    name          = "vnet-no-subnets"
    address_space = ["10.0.0.0/24"]

    dns_servers             = ["10.0.0.4", "10.0.0.5"]
    edge_zone               = "example"
    flow_timeout_in_minutes = 10
  },

  # Virtual Network with Subnets
  {
    name          = "vnet-with-subnets"
    address_space = ["10.0.1.0/24"]

    subnets = [
      # Subnet with no NSG or Route Table
      {
        name             = "snet-no-nsg-rt"
        address_prefixes = ["10.0.1.0/27"]
      },

      # Subnet with empty NSG and Route Table
      {
        name             = "snet-nsg-rt-empty"
        address_prefixes = ["10.0.1.32/27"]

        # NSG with no Rules
        network_security_group = {
          name = "nsg-no-rules"
        }

        # Route Table with no Routes
        route_table = {
          name = "rt-no-routes"
        }
      },

      # Subnet with NSG and Route Table
      {
        name             = "snet-nsg-rt"
        address_prefixes = ["10.0.1.64/27"]

        # NSG with Rules
        network_security_group = {
          name = "nsg-with-rules"

          rules = [
            {
              name                    = "winrm"
              priority                = "500"
              direction               = "Inbound"
              access                  = "Allow"
              protocol                = "Tcp"
              source_port_range       = "*"
              destination_port_range  = "5985"
              source_address_prefixes = ["0.0.0.0/0"]
            },
            {
              name                       = "DenyAllOutbound"
              priority                   = "1000"
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*"
              source_port_range          = "*"
              destination_port_range     = "*"
              destination_address_prefix = "0.0.0.0/0"
            },
          ]
        }

        # Route Table with Routes
        route_table = {
          name = "rt-with-routes"

          routes = [
            {
              name                   = "internal-subnet"
              address_prefix         = "10.0.0.0/27"
              next_hop_type          = "VirtualAppliance"
              next_hop_in_ip_address = "10.0.0.4"
            },
            {
              name           = "internet"
              address_prefix = "0.0.0.0/0"
              next_hop_type  = "Internet"
            }
          ]
        }
      },

      # Subnet associated with existing NSG and Route Table
      {
        name             = "snet-existing-nsg-rt"
        address_prefixes = ["10.0.1.96/27"]

        existing_network_security_group = {
          name = "nsg-existing"
        }

        existing_route_table = {
          name = "rt-existing"
        }
      },

      # Subnet with Delegations
      {
        name             = "snet-delegations"
        address_prefixes = ["10.0.1.128/27"]

        delegations = [
          {
            name = "aci-delegation"
            service_delegation = {
              name    = "Microsoft.ContainerInstance/containerGroups"
              actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
            }
          }
        ]
      },

      # Subnet with Service Endpoints
      {
        name             = "snet-service-endpoints"
        address_prefixes = ["10.0.1.160/27"]

        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.Sql",
          "Microsoft.KeyVault"
        ]
      },
    ]
  },

  # Virtual Network with Peerings
  {
    name          = "vnet-with-peerings"
    address_space = ["10.0.2.0/24"]

    peerings = [
      {
        remote_virtual_network = {
          name = "vnet-with-subnets"
        }

        source_to_remote_config = {
          allow_fowarded_traffic = true
        }

        remote_to_source_config = {
          allow_fowarded_traffic = true
        }
      },
      {
        remote_virtual_network = {
          name = "vnet-no-subnets"
        }

        source_to_remote_config = {
          allow_fowarded_traffic = true
        }

        remote_to_source_config = {
          allow_fowarded_traffic = true
        }
      }
    ]
  }
]
