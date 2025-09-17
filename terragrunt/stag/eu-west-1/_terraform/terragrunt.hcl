include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "_env" {
  path = "${find_in_parent_folders("_env")}/_terraform-monolith/terragrunt.hcl"
}

inputs = {
  environment = include.root.inputs.environment
}
