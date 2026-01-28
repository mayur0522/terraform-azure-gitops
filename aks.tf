resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D4ds_v5"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
    value = data.azurerm_resource_group.rg.name
}
