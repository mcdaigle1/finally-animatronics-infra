resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  repository   = "https://kubernetes.github.io/ingress-nginx"
  chart        = "ingress-nginx"
  version      = "4.15.1" 
  timeout      = 600 # 10m
  wait         = true
  force_update = true

  values = [file("${path.module}/nginx-values.yaml")]
}

resource "kubernetes_ingress_v1" "finally_animatronics_ingress" {
  metadata {
    name      = "finally-animatronics-ingress"
    namespace = "prod"

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/use-regex"    = "false"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "api.finallyanimatronics.com"

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