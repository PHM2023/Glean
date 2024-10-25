resource "aws_cloudwatch_log_group" "rds_os_metrics" {
  name              = "RDSOSMetrics"
  retention_in_days = 30 # To match what RDS does
}

resource "aws_cloudwatch_log_metric_filter" "rds_active_memory_metric_filter" {
  name           = "RdsActiveMemory"
  pattern        = "{ $.memory.active = %\\d+% && $.instanceID = %.% }"
  log_group_name = aws_cloudwatch_log_group.rds_os_metrics.name

  metric_transformation {
    name      = "ActiveMemory"
    namespace = "RdsOsMetrics"
    value     = "$.memory.active"
    dimensions = {
      DBInstanceIdentifier = "$.instanceID"
    }
    unit = "Kilobytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "rds_total_memory_metric_filter" {
  name           = "RdsTotalMemory"
  pattern        = "{ $.memory.total = %\\d+% && $.instanceID = %.% }"
  log_group_name = aws_cloudwatch_log_group.rds_os_metrics.name

  metric_transformation {
    name      = "TotalMemory"
    namespace = "RdsOsMetrics"
    value     = "$.memory.total"
    dimensions = {
      DBInstanceIdentifier = "$.instanceID"
    }
    unit = "Kilobytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "rds_cpu_utilization_metric_filter" {
  name           = "RdsCpuUtilization"
  pattern        = "{ $.cpuUtilization.total = %\\d+% && $.instanceID = %.% }"
  log_group_name = aws_cloudwatch_log_group.rds_os_metrics.name

  metric_transformation {
    name      = "CpuUtilization"
    namespace = "RdsOsMetrics"
    value     = "$.cpuUtilization.total"
    dimensions = {
      DBInstanceIdentifier = "$.instanceID"
    }
    unit = "Percent"
  }
}
