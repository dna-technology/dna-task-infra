module "ssm" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name   = "example"
  values = ["secret1", "item2"]
}