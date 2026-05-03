resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  repository   = "https://kubernetes.github.io/ingress-nginx"
  chart        = "ingress-nginx"
  version      = "4.12.3" # use latest compatible with your k8s
  timeout      = 600 # 10m
  wait         = true
  force_update = true

  values = [file("${path.module}/nginx-values.yaml")]
}

resource "kubernetes_ingress_v1" "finally-animatronics" {
  metadata {
    name      = "finally-animatronics-ingress"
    namespace = "dev"

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/use-regex"    = "false"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "api.finally-animatronics.com"

      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "finally-animatronics-api-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}