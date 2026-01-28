resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # If you want to disable TLS for the ArgoCD server (not recommended for production)
  # set {
  #   name  = "server.insecure"
  #   value = "true"
  # }
}
