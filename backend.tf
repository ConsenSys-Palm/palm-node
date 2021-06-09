terraform {
  backend "remote" {
    organization = "niftys"

    workspaces {
      name = "palm-node"
    }
  }
}