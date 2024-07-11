locals {
  label_order = ["namespace", "environment", "stage", "name", "attributes"]
  namespace   = "dna"
  environment = "euw"
  name        = "jp2"
  team        = "DNA"

  tags = {
    Terraform     = "true"
    Organisation  = "Digital New Agency"
    Product       = "Barka"
    CostCenter    = "2137"
  }
}
