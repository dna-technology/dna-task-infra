data "aws_partition" "current" {}

resource "aws_iam_role_policy_attachment" "restore" {
  count      = var.enabled && var.restore_enabled ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = var.iam_role_name
}

resource "aws_iam_role_policy_attachment" "s3backup" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = var.iam_role_name
}

resource "aws_iam_role_policy_attachment" "s3restore" {
  count      = var.enabled && var.restore_enabled ? 1 : 0
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = var.iam_role_name
}
