resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.rds_subnets
}

resource "aws_iam_role" "rds_enhanced_monitoring_role" {
  name                 = "RdsEnhancedMonitoringRole"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring_permissions_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_enhanced_monitoring_role.name
}

###################  BE SQL ###################
module "backend_parameter_group" {
  source               = "./parameter_group"
  long_query_time      = var.backend_long_query_time
  slow_query_log       = var.backend_slow_query_log
  parameter_group_name = var.backend_parameter_group_name
  instance_specific_flags = {
    innodb_purge_batch_size              = "5000"
    innodb_purge_threads                 = "32"
    innodb_purge_rseg_truncate_frequency = "1"
    innodb_max_purge_lag                 = "10000000"
    innodb_max_purge_lag_delay           = "100000"
  }
}

module "backend_rds_instance" {
  source                  = "./rds_instance"
  instance_identifier     = var.backend_instance_identifier
  instance_class          = var.backend_instance_class
  storage                 = var.backend_instance_storage
  max_storage             = var.max_storage
  mysql_version           = var.mysql_version
  rds_security_group      = var.rds_security_group
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.backend_backup_retention_period
  parameter_group_name    = module.backend_parameter_group.parameter_group_name
  monitoring_role_arn     = aws_iam_role.rds_enhanced_monitoring_role.arn
  additional_tags = {
    "glean_config_index" : "backendInstance"
  }
  # Ensure the OS metrics log group is created and managed by terraform first before automatically provisioned by the instance creation
  depends_on = [aws_cloudwatch_log_group.rds_os_metrics]
}

# For multi-instance for document store
module "backend_rds_instance_2" {
  source                  = "./rds_instance"
  instance_identifier     = var.backend_instance_2_identifier
  instance_class          = var.backend_instance_class
  storage                 = var.backend_instance_storage
  max_storage             = var.max_storage
  mysql_version           = var.mysql_version
  rds_security_group      = var.rds_security_group
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.backend_backup_retention_period
  parameter_group_name    = module.backend_parameter_group.parameter_group_name
  monitoring_role_arn     = aws_iam_role.rds_enhanced_monitoring_role.arn
  count                   = var.backend_multi_instance_count
  additional_tags = {
    "glean_config_index" : "backendInstance2"
  }
  # Ensure the OS metrics log group is created and managed by terraform first before automatically provisioned by the instance creation
  depends_on = [aws_cloudwatch_log_group.rds_os_metrics]
}

###################  FE SQL ###################
module "frontend_parameter_group" {
  source               = "./parameter_group"
  long_query_time      = var.frontend_long_query_time
  slow_query_log       = var.frontend_slow_query_log
  parameter_group_name = var.frontend_parameter_group_name
}

module "frontend_rds_instance" {
  source                  = "./rds_instance"
  instance_identifier     = var.frontend_instance_identifier
  instance_class          = var.frontend_instance_class
  storage                 = var.frontend_instance_storage
  max_storage             = var.max_storage
  mysql_version           = var.mysql_version
  rds_security_group      = var.rds_security_group
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  backup_retention_period = var.frontend_backup_retention_period
  parameter_group_name    = module.frontend_parameter_group.parameter_group_name
  monitoring_role_arn     = aws_iam_role.rds_enhanced_monitoring_role.arn
  additional_tags = {
    "glean_config_index" : "frontendInstance"
  }
  # Ensure the OS metrics log group is created and managed by terraform first before automatically provisioned by the instance creation
  depends_on = [aws_cloudwatch_log_group.rds_os_metrics]
}

# The following IAM policy should be attached to the IAM roles of all the services
# ... who will be accessing SQL (Ex: k8s service account of crawlers, dse, admin, qe, qp)
resource "aws_iam_policy" "sql_connect_policy" {
  name        = "GleanRdsConnect"
  description = "Connecting to both RDS instances as the glean IAM user"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds-db:connect"
        ],
        "Resource" : [
          "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:*/${var.db_user}",
          "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:*/${var.db_debug_user}"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "root_sql_access_policy" {
  name = "GleanRootSqlAccess"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDbInstances"
        ],
        "Resource" : [
          module.frontend_rds_instance.rds_instance_arn,
          module.backend_rds_instance.rds_instance_arn,
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          module.frontend_rds_instance.root_secret_arn,
          module.backend_rds_instance.root_secret_arn,
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:TagRole"
        ],
        "Resource" : [
          # Not using a tf value since this role is created after the first instance is up
          "arn:aws:iam::${var.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
        ]
      }
    ]
  })
}
