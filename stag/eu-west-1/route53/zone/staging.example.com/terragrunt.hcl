include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "_env" {
  path = "${find_in_parent_folders("_env")}/route53/zone/environment.example.com/terragrunt.hcl"
}

inputs = {

}