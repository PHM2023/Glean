resource "aws_db_instance" "rds_instance" {
  identifier     = var.instance_identifier
  instance_class = var.instance_class
  # This is the initial storage
  # max_allocated_storage is the upper limit of autoscaling by rds
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#storage-autoscaling
  allocated_storage     = var.storage
  max_allocated_storage = var.max_storage
  storage_type          = "gp3"
  storage_encrypted     = "true"
  engine                = "mysql"
  engine_version        = var.mysql_version
  # keep the minor version pinned
  auto_minor_version_upgrade = false
  # root user is password authenticated. We let aws manage the password
  # AWS will store the secret in secrets manager (will also rotate the password automatically).
  # Since we rely on IAM auth anyway, we let the root user password be aws managed
  username                              = "root"
  iam_database_authentication_enabled   = true
  performance_insights_enabled          = true
  performance_insights_retention_period = 31
  monitoring_interval                   = 30
  monitoring_role_arn                   = var.monitoring_role_arn
  manage_master_user_password           = true
  vpc_security_group_ids                = [var.rds_security_group]
  db_subnet_group_name                  = var.db_subnet_group_name
  maintenance_window                    = var.maintenance_window
  backup_window                         = var.backup_window
  backup_retention_period               = var.backup_retention_period
  final_snapshot_identifier             = "${var.instance_identifier}-backup"
  publicly_accessible                   = false
  copy_tags_to_snapshot                 = true
  parameter_group_name                  = var.parameter_group_name
  tags = merge({
    Name = var.instance_identifier
  }, var.additional_tags)
  ca_cert_identifier = "rds-ca-ecc384-g1"
  lifecycle {
    # To unblock releases regarding SETUP_SQL needing to destroy and create the instance
    ignore_changes = [
      storage_encrypted
    ]
    # Do not delete: this should be a permanent change so the rds instance never gets deleted. We don't want this to happen at all.
    prevent_destroy = true
  }
}
