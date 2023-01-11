resource "aws_route53_record" "web" {
  count = length(var.route53_zone_id) > 0 ? var.web_instance_count : 0
  zone_id = var.route53_zone_id
  name    = aws_instance.web[count.index].tags["Name"]
  type    = "A"
  ttl     = 300
  records = [aws_eip.web[count.index].public_ip]
}

resource "aws_route53_record" "worker" {
  count = length(var.route53_zone_id) > 0 ? var.worker_instance_count : 0
  zone_id = var.route53_zone_id
  name    = aws_instance.worker[count.index].tags["Name"]
  type    = "A"
  ttl     = 300
  records = [aws_eip.worker[count.index].public_ip]
}

resource "aws_route53_record" "lb" {
  count = length(var.route53_zone_id) > 0 ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.lb_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.production.dns_name
    zone_id                = aws_lb.production.zone_id
    evaluate_target_health = true
  }
}

