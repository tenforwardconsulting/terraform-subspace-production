# Global (e.g. include -var-file=../global.vars)

variable aws_region { type = string }
variable project_name { type = string }
variable project_environment { type = string }
variable instance_ami { type = string }
variable subspace_public_key { type = string }
variable ssh_cidr_blocks { type = list }

# worker.tf
variable worker_instance_type { type = string }
variable worker_instance_count { type = number }
variable worker_volume_size {
  type = number
  default = 32 #GB
}

# web.tf
variable web_instance_type { type = string }
variable web_instance_count { type = number }
variable web_volume_size {
  type = number
  default = 16 #GB
}

# load_balancer.tf
variable route53_zone_id {
  type = string
  default = ""
}

variable lb_domain_name {
  type = string
  default = ""
}
variable lb_alternate_names {
  type = list(string)
  default = []
}
variable lb_certificate_arn {
  type = string
  default = null
}
variable lb_health_check_path { type = string }

# database.tf
variable database_engine { type = string }
variable database_engine_version { type = string }
variable database_instance_class { type = string }
variable database_name { type = string }
variable database_username { type = string }
variable database_password { type = string }
variable database_allocated_storage { type = number }
variable database_max_allocated_storage { type = number }
variable database_iops { type = number }
variable final_snapshot_identifier { type = string }
variable snapshot_identifier {
  type = string
  default = null
}

# role.tf
variable delegated_access_account_id {
  type = string
  default = ""
}

# redis.tf
variable redis_node_count {
  type = number
  default = 0
}
variable redis_node_type {
  type = string
  default = ""
}
variable redis_parameter_group_name {
  type = string
  default = "default.redis7"
}
variable redis_engine_version {
  type = string
  default = "7.0"
}
variable redis_apply_immediately {
  type = bool
  default = false
}

variable "rds_security_group_ingress_description" {
  type = string
  default = "PSQL traffic from webservers and workers"
}

variable "rds_security_group_ingress_security_groups" {
  type = list(string)
  nullable = true
}
