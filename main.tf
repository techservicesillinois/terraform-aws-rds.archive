locals {
  final_snapshot_identifier = "${var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : format("%s-FINAL", var.identifier)}"
  security_group_names      = "${compact(split(" ", var.security_group_names))}"

  # TODO: Rethink how to make restoring from snapshot and destroying with snapshot
  # more foolproof.
  # snapshot_identifier = "${var.snapshot_identifier != "" ? var.snapshot_identifier : format("%s", var.identifier)}"
}

data "aws_security_group" "selected" {
  count = "${length(local.security_group_names)}"
  name  = "${local.security_group_names[count.index]}"
}

resource "aws_db_instance" "default" {
  identifier                          = "${var.identifier}"
  engine                              = "${var.engine}"
  engine_version                      = "${var.engine_version}"
  instance_class                      = "${var.instance_class}"
  allocated_storage                   = "${var.allocated_storage}"
  storage_type                        = "${var.storage_type}"
  storage_encrypted                   = "${var.storage_encrypted}"
  kms_key_id                          = "${var.kms_key_id}"
  license_model                       = "${var.license_model}"
  name                                = "${var.name}"
  username                            = "${var.username}"
  password                            = "${var.password}"
  port                                = "${var.port}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"
  replicate_source_db                 = "${var.replicate_source_db}"
  snapshot_identifier                 = "${var.snapshot_identifier}"
  vpc_security_group_ids              = ["${data.aws_security_group.selected.*.id}"]
  availability_zone                   = "${var.availability_zone}"
  multi_az                            = "${var.multi_az}"
  iops                                = "${var.iops}"
  publicly_accessible                 = "${var.publicly_accessible}"
  monitoring_interval                 = "${var.monitoring_interval}"

  # monitoring_role_arn = "${coalesce(var.monitoring_role_arn, join("", aws_iam_role.enhanced_monitoring.*.arn))}"
  allow_major_version_upgrade     = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade      = "${var.auto_minor_version_upgrade}"
  apply_immediately               = "${var.apply_immediately}"
  maintenance_window              = "${var.maintenance_window}"
  skip_final_snapshot             = "${var.skip_final_snapshot}"
  copy_tags_to_snapshot           = "${var.copy_tags_to_snapshot}"
  final_snapshot_identifier       = "${local.final_snapshot_identifier}"
  backup_retention_period         = "${var.backup_retention_period}"
  backup_window                   = "${var.backup_window}"
  character_set_name              = "${var.character_set_name}"
  enabled_cloudwatch_logs_exports = "${var.enabled_cloudwatch_logs_exports}"
  timeouts                        = "${var.timeouts}"
  deletion_protection             = "${var.deletion_protection}"
  tags                            = "${merge(map("Name", var.identifier), var.tags)}"
  db_subnet_group_name            = "${var.db_subnet_group_name}"
  parameter_group_name            = "${var.parameter_group_name}"
  option_group_name               = "${var.option_group_name}"
}
