# Using a single workspace:
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "RPT"

    workspaces {
      name = "vault_azure"
    }
  }
}