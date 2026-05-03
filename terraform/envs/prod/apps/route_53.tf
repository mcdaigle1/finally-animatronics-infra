data "aws_route53_zone" "primary" {
  name         = "finallyanimatronics.com."
  private_zone = false 
}

resource "aws_route53_record" "api_cname" {
  zone_id = data.aws_route53_zone.primary.id
  name    = "api.finallyanimatronics.com"
  type    = "CNAME"
  ttl     = 300
  records = [kubernetes_ingress_v1.finally_animatronics_ingress.status.0.load_balancer.0.ingress.0.hostname]
}