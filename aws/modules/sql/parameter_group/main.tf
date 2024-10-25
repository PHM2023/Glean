resource "aws_db_parameter_group" "parameter_group" {
  name        = var.parameter_group_name
  family      = "mysql8.0"
  description = "Custom MySQL parameter group with custom flags"

  parameter {
    name  = "character_set_server"
    value = var.character_set_server
  }
  parameter {
    name  = "event_scheduler"
    value = var.event_scheduler
  }
  parameter {
    name  = "innodb_online_alter_log_max_size"
    value = var.innodb_online_alter_log_max_size
  }
  parameter {
    name  = "log_bin_trust_function_creators"
    value = var.log_bin_trust_function_creators
  }
  parameter {
    name  = "log_output"
    value = var.log_output
  }
  parameter {
    name  = "long_query_time"
    value = var.long_query_time
  }
  parameter {
    name  = "max_allowed_packet"
    value = var.max_allowed_packet
  }
  parameter {
    name  = "slow_query_log"
    value = var.slow_query_log
  }
  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  # some flags are static and require a reboot to be applied,
  # like innodb_purge_threads
  # ref: https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html
  dynamic "parameter" {
    for_each = var.instance_specific_flags
    content {
      name  = parameter.key
      value = parameter.value
      apply_method = contains([
        "innodb_purge_threads",
      ], parameter.key) ? "pending-reboot" : "immediate"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
