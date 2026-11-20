data "aws_route53_zone" "public" {
  count        = local.dns
  name         = var.dns_zone
  private_zone = false
}

resource "aws_acm_certificate" "this" {
  count                     = local.own_cert
  domain_name               = var.ui_name
  subject_alternative_names = concat([var.ingest_name], var.monitoring == "ecs" ? [local.grafana_name] : [])
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for option in local.own_cert == 1 ? aws_acm_certificate.this[0].domain_validation_options : [] : option.domain_name => option
  }
  zone_id         = data.aws_route53_zone.public[0].zone_id
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  records         = [each.value.resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  count                   = local.own_cert
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_route53_record" "ui_public" {
  count   = local.ui_public * local.dns
  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.ui_name
  type    = "A"
  alias {
    name                   = aws_lb.ui_public[0].dns_name
    zone_id                = aws_lb.ui_public[0].zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ingest" {
  count   = local.dns
  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.ingest_name
  type    = "A"
  alias {
    name                   = local.ingest_lb.dns_name
    zone_id                = local.ingest_lb.zone_id
    evaluate_target_health = false
  }
}

# Inside the VPC the UI name points at the internal load balancer, the module's
# own or the user's, so a server in an allowed security group reaches it by the
# same name.
resource "aws_route53_zone" "ui_private" {
  count         = local.internal * local.dns
  name          = var.ui_name
  force_destroy = true
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "ui_private" {
  count   = local.internal * local.dns
  zone_id = aws_route53_zone.ui_private[0].zone_id
  name    = var.ui_name
  type    = "A"
  alias {
    name                   = local.internal_lb.dns_name
    zone_id                = local.internal_lb.zone_id
    evaluate_target_health = false
  }
}

# The addresses of the module before the certificate and the records could be the user's.
moved {
  from = aws_acm_certificate.this
  to   = aws_acm_certificate.this[0]
}

moved {
  from = aws_acm_certificate_validation.this
  to   = aws_acm_certificate_validation.this[0]
}

moved {
  from = aws_route53_record.ingest
  to   = aws_route53_record.ingest[0]
}
