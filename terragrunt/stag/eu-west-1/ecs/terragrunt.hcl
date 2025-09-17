include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "_env" {
  path = "${find_in_parent_folders("_env")}/ecs/cluster/public/terragrunt.hcl"
}

inputs = {
  fargate_capacity_providers = {
    FARGATE = {}
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
}