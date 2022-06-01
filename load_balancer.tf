resource "aws_security_group" "oxenwagen-load-balancer" {
  name        = "${var.project_name}-${var.project_environment}-lb"
  description = "${var.project_name} ${var.project_environment} load balancer"
  vpc_id      = aws_vpc.oxenwagen-internal.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description      = "HTTP from world"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS from world"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "oxenwagen" {
  name               = "${var.project_name}-${var.project_environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.oxenwagen-load-balancer.id]
  subnets            = [aws_subnet.oxenwagen-internal-a.id, aws_subnet.oxenwagen-internal-b.id, aws_subnet.oxenwagen-internal-c.id]
  idle_timeout       = 60

  enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.oxenwagen.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oxenwagen[0].arn
  }
}

resource "aws_lb_target_group" "oxenwagen" {
  count    = 1
  name     = "${var.project_name}-${var.project_environment}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.oxenwagen-internal.id
  health_check {
    enabled             = true
    matcher             = "200,301"
    port                = "80"
    protocol            = "HTTP"
    path                = var.lb_health_check_path
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = var.web_instance_count
  target_group_arn = aws_lb_target_group.oxenwagen[0].arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}


### HTTPS / TLS Configuration
# Skip this is lb_domain_name is blank
resource "aws_acm_certificate" "oxenwagen" {
  count = length(var.lb_domain_name) > 0 ? 1 : 0
  domain_name               = var.lb_domain_name
  subject_alternative_names = var.lb_alternate_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  cert_arn = length(var.lb_domain_name) > 0 ? aws_acm_certificate.oxenwagen[0].arn : var.lb_certificate_arn
}

resource "aws_lb_listener" "tls" {
  count = length(var.lb_domain_name) > 0 || var.lb_certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.oxenwagen.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = aws_acm_certificate.oxenwagen[0].arn
  certificate_arn   = local.cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oxenwagen[0].arn
  }
}
