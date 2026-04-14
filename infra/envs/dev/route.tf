import {
  to = aws_route53_zone.main
  id = "Z0288653I2KD4K3FI7L2"
}

resource "aws_route53_zone" "main" {
  name    = "kriszboutique.click"
  comment = "HostedZone created by Route53 Registrar"

  # optional but avoids drift
  force_destroy = false
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "kriszboutique.click"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.kriszboutique.click"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}