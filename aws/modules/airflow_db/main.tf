data "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
}

resource "random_password" "airflow_rds_instance_root_password" {
  length = 16
}

resource "aws_secretsmanager_secret" "airflow_rds_instance_root_password" {
  name = "airflow_rds_instance_root_password"
}

resource "aws_secretsmanager_secret_version" "airflow_rds_instance_root_password" {
  secret_id     = aws_secretsmanager_secret.airflow_rds_instance_root_password.id
  secret_string = random_password.airflow_rds_instance_root_password.result
}

resource "aws_db_instance" "airflow_rds_instance" {
  identifier     = "airflow-instance"
  instance_class = var.airflow_instance_class
  # This is the initial storage
  # max_allocated_storage is the upper limit of autoscaling by rds
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#storage-autoscaling
  allocated_storage                   = var.storage
  max_allocated_storage               = var.max_storage
  engine                              = "mysql"
  engine_version                      = var.mysql_version
  username                            = "root" # Using root user as password auth is only supported for root user
  password                            = random_password.airflow_rds_instance_root_password.result
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [var.rds_security_group]
  db_subnet_group_name                = data.aws_db_subnet_group.rds_subnet_group.name
  final_snapshot_identifier           = "airflow-instance-backup"
  publicly_accessible                 = false
}
