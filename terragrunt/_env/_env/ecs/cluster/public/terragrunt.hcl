locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl")) # This works because find_in_parent_folders always works at the context of the child configuration.
  vars        = merge(local.global_vars.locals, local.env_vars.locals)
  path_dirs   = regex("([\\w\\-\\_\\.]+)\\/([\\w\\-\\_\\.]+)$", get_terragrunt_dir()) # it returns array contains name of the directory in directory path started from the last one
  name        = join("-", reverse(local.path_dirs))
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=latest"
}

inputs = {
  enable       = true
  cluster_name = format("%s-%s-%s-%s-%s", local.vars.namespace, local.vars.slug, local.vars.environment, local.name)

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 0

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096

      container_definitions = {

        fluent-bit = {
          cpu                    = 512
          memory                 = 1024
          essential              = true
          image                  = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        ecs-sample = {
          cpu           = 512
          memory        = 1024
          essential     = true
          image         = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          readonly_root_filesystem = true

          dependencies = [
            {
              containerName = "fluent-bit"
              condition     = "START"
            }
          ]

          enable_cloudwatch_logging = false
          log_configuration         = {
            logDriver = "awsfirelens"
            options   = {
              Name                    = "firehose"
              region                  = "eu-west-1"
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = "example"
        service   = {
          client_alias = {
            port     = 80
            dns_name = "ecs-sample"
          }
          port_name      = "ecs-sample"
          discovery_name = "ecs-sample"
        }
      }

      load_balancer = {
        service = {
          target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
          container_name   = "ecs-sample"
          container_port   = 80
        }
      }

      subnet_ids           = dependency.vpc.output.subnet_ids
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = "sg-12345678"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}