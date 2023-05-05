terraform {
  required_version = ">= 1.0.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "1.24.3"
    }
      vault = {
      source  = "hashicorp/vault"
      version = ">=2.7"
    }
  }
}
