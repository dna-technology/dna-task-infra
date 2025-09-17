variable "environment" {
  type = string
}

variable "aws_env_map" {
  type        = map(string)
  description = "Environment name"

  default = {
    prod    = "prod"
    nonprod = "nonprod"
    test    = "test"
  }
}

variable "namespace" {
  default     = "example"
}

variable "create_tgw" {
  type        = map(bool)

  default = {
    prod    = true
    nonprod = true
    test    = false
  }
}

variable "ssm_configuration_enabled" {
  type        = map(bool)
  description = "SSM configuration of account is created on production environment"

  default = {
    prod    = true
    nonprod = false
    test     = false
  }
}

variable "firewall_configuration_enabled" {
  type        = map(bool)
  description = "Firewall Manager Policy of account is created on production environment"

  default = {
    prod    = true
    nonprod = false
    test     = false
  }
}

variable "backup_account-enabled" {
  type = map(bool)

  default = {
    prod    = true
    nonprod = false
    test     = false
  }
}
