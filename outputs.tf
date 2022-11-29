output web_instance_ips {
  value = aws_eip.web[*].public_ip
}
output worker_instance_ips {
  value = aws_eip.worker[*].public_ip
}
output certification_dns_options {
  value = aws_acm_certificate.production[*].domain_validation_options
}

output database_endpoint {
  value = aws_db_instance.production.endpoint
}

output inventory {
  value = {
    hostnames = concat(aws_instance.web[*].tags_all.Name, aws_instance.worker[*].tags_all.Name)
    ip_addresses = concat(aws_eip.web[*].public_ip, aws_eip.worker[*].public_ip)
    groups = concat([ for i in aws_instance.web : "${var.project_environment} ${var.project_environment}_web" ], [ for i in aws_instance.worker : "${var.project_environment} ${var.project_environment}_worker" ])
    users = concat([ for i in aws_instance.web : "ubuntu"], [ for i in aws_instance.worker : "ubuntu"] )
  }
}

data "aws_caller_identity" "current" {}

output switch_role_url {
  value = "https://signin.aws.amazon.com/switchrole?roleName=DelegatedAccess&account=${data.aws_caller_identity.current.account_id}&displayName=${var.project_name}"
}

output lb_http_arn {
  value = aws_lb_listener.http.arn
}

output tls_http_arn {
  value = aws_lb_listener.tls[0].arn
}

output "redis_nodes" {
  value = aws_elasticache_cluster.redis[0].cache_nodes
}
