#variables.tf

variable "vault_address" {
  description = "Hashicorp Vault FQDN and port"
}

variable "role_id" {
  description = "role-id token"
  sensitive = true
}

variable "vsphere_server" {
  description = "vCenter server FQDN or IP"
  
}


#VM Location

variable "vsphere_datacenter" {
  description = "vSphere datacenter"
  default     = "IPT"
  type        = string
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  type        = string
}

variable "vsphere_folder" {
  description = "vSphere folder where to create the VM"
  type        = string
}

variable "datastore" {
  description = "datastores available for storage allocation. By name ex: datastore1,datastore2"
  type        = string
}

