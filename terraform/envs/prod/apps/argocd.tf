resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.5.11"

  values = [file("${path.module}/argocd-values.yaml")]

  timeout = 600
  wait    = true

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}