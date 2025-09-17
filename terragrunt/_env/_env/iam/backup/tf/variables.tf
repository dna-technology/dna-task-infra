variable "restore_enabled" {
  type        = bool
  description = "Enable restore polices in the IAM role"
}

variable "iam_role_name" {
  type        = string
  description = "Name of IAM role"
}
