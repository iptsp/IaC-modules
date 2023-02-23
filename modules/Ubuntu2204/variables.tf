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

variable "vsphere_user" {
  description = "vSphere username to use to connect to the environment"
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  sensitive   = true
}

variable "ubuntu_user" {
  description = "Username to use to connect ssh and run provisioning shell "
  type        = string
  sensitive   = true
}

variable "ubuntu_password" {
  description = "Password to use to connect ssh and run provisioning shell "
  type        = string
  sensitive   = true
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




# Virtual Machine Settings

# for vault vm

variable "vm_cpus" {
  description = "Number of CPUs"  
  type        = number
  default     = 4
}

variable "vm_memory" {
  description = "Memory in MB"
  type        = number
  default      = 8196

}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "vsphere_network" {
  description = "vSphere network"
  type        = string
  
}

variable "vsphere_template" {
  description = "vSphere template which will be used to create the VM"
  type        = string
  default     = "UbuntuServer2204packer"
}

# VM customization

variable "vm_name" {
  description = "New VM's Name"
  type        = string
  
}

variable "domain" {
  description = "Domain name"
  type        = string
  
}

variable "dns_servers_list" {
  description = "DNS server list format ['xxx.xxx.xxx.xxx',xx.xx.xx.xx' ]"
  type        = list
  
}

variable "ip_address" {
  description = "VM Ipv4 Address"
  type        = string
  
}

variable "cidr" {
  description = "CIDR for netmask formation. two digits ex. 10.11.39.0/XX  XX=16"
  type        = number
}

variable "vsphere_network_gateway" {
  description = "vSphere network gateway"
  type        = string
  
}