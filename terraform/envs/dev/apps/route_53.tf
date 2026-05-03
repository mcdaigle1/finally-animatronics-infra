data "aws_route53_zone" "primary" {
  name         = "finally-animatronics.com"
  private_zone = false 
}

resource "aws_route53_record" "api_cname" {
  zone_id = data.aws_route53_zone.primary.id
  name    = "api.finally-animatronics.com"
  type    = "CNAME"
  ttl     = 300
  records = [kubernetes_ingress_v1.finally-animatronics.status.0.load_balancer.0.ingress.0.hostname]
}

# resource "aws_route53_record" "api_cname" {
#   zone_id = data.aws_route53_zone.primary.id
#   name    = "api.finally-animatronics.com"
#   type    = "CNAME"
#   ttl     = 300
#   records = [kubernetes_ingress_v1.finally-animatronics.status.0.load_balancer.0.ingress.0.hostname]
# }