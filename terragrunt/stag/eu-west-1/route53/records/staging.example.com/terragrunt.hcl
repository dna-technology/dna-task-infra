include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "_env" {
  path = "${find_in_parent_folders("_env")}/route53/records/environment.example.com/terragrunt.hcl"
  expose = true
}

inputs = {
  records = [
        {
          create = true
          name   = local.zone_name
          type   = "NS"
          ttl    = "3600"
          records = [
            "CHANGE_ME",
            "CHANGE_ME",
            "CHANGE_ME",
            "CHANGE_ME"
          ]
        }
  ]
}