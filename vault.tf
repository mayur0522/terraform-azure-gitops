resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true

  set {
    name  = "server.dev.enabled"
    value = "true"
  }
  
  set {
      name = "ui.enabled"
      value = "true"
  }
  
  set {
      name = "ui.service.type"
      value = "LoadBalancer"
  }

  # Enable the Vault Agent Injector
  set {
    name  = "injector.enabled"
    value = "true"
  }
}
