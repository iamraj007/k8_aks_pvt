resource "azurerm_resource_group" "k8" {
  name     = "k8-resources"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "k8" {
  name                    = "k8-aks"
  location                = azurerm_resource_group.k8.location
  resource_group_name     = azurerm_resource_group.k8.name
  dns_prefix              = "k8aks"
  private_cluster_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
  #  identity {
  #    type         = "UserAssigned"
  #    identity_ids = [data.azurerm_user_assigned_identity.identity.id]
  #  }
}


###########
data "azurerm_user_assigned_identity" "identity" {
  name                = var.user_assigned_identity_id
  resource_group_name = var.user_assigned_identity_resource_group
}

data "azurerm_client_config" "current" {
}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}
##########

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8.kube_config.0.host
  username               = azurerm_kubernetes_cluster.k8.kube_config.0.username
  password               = azurerm_kubernetes_cluster.k8.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8.kube_config.0.cluster_ca_certificate)
  #  load_config_file = "false"
}


resource "null_resource" "get_k8_ns" {

  provisioner "local-exec" {
    command = "az aks command invoke --resource-group k8-resources --name k8-aks --command 'kubectl get ns' "
  }
  depends_on = [azurerm_kubernetes_cluster.k8]
}


resource "null_resource" "get-k8_all" {
  provisioner "local-exec" {
    command = "az aks command invoke --resource-group k8-resources --name k8-aks --command 'kubectl get all -A' "
  }
  depends_on = [azurerm_kubernetes_cluster.k8]
}

/*
resource "kubernetes_namespace" "namespace" {
  metadata {
    labels = {
      app = "create-namespace"
    }
    name = "k9demo-ns"
  }
  depends_on = [azurerm_kubernetes_cluster.k8]
}
*/


/*
data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.k8.name
  resource_group_name = azurerm_resource_group.k8.name
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
  }
}


resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress-controller"
  namespace = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}

# data "kubernetes_service" "chartloadbalancer" {
#   metadata {
#     name = helm_release.nginx_ingress.name
#     namespace = helm_release.nginx_ingress.namespace
#   }
# }
*/

