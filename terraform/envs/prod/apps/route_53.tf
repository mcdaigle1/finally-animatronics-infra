data "aws_route53_zone" "primary" {
  name         = "finallyanimatronics.com."
  private_zone = false
}

data "kubernetes_service_v1" "nginx_ingress_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}

resource "aws_route53_record" "api_cname" {
  zone_id = data.aws_route53_zone.primary.id
  name    = "api.finallyanimatronics.com"
  type    = "CNAME"
  ttl     = 300

  records = [
    data.kubernetes_service_v1.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
  ]
}