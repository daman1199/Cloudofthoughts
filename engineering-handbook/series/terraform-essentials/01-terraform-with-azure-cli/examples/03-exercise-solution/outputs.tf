output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_web_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "subnet_data_id" {
  description = "ID of the data subnet"
  value       = azurerm_subnet.data.id
}
