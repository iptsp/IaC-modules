#Vault init

provider "vault" {
  
  address  = var.vault_address
  auth_login {
    
    path = "auth/approle/login"
    
    parameters = {
      role_id   = var.role_id
      
    }
  }
}



##### Data sources

#data "vault_approle_auth_backend_role_id" "terraform" {
##  backend   = "approle"
#  role_name = "terraform"
#}

#output "role-id" {
#  value = data.vault_approle_auth_backend_role_id.terraform.role_id
#}

resource "vault_approle_auth_backend_login" "login" {
  backend   = "approle"
  role_id   = var.role_id #data.vault_approle_auth_backend_role_id.terraform.role_id
  
}

#Reading vmware secret

data "vault_kv_secret_v2" "vcenter" {
  mount     = "vmware"
  name      = "vcenter"
}

data "vault_kv_secret_v2" "user_credentials" {
  mount     = "servers/Windows"
  name      = "build"
}

provider "vsphere" {
  user                = nonsensitive(data.vault_kv_secret_v2.vcenter.data["user"])
  password            = nonsensitive(data.vault_kv_secret_v2.vcenter.data["password"])
  vsphere_server      = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

##### Data sources
data "vsphere_datacenter" "IPT" {
  name                 = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name                 = var.vsphere_cluster
  datacenter_id        = data.vsphere_datacenter.IPT.id
}

data "vsphere_network" "network" {
  name                 = var.vsphere_network
  datacenter_id        = data.vsphere_datacenter.IPT.id
}

data "vsphere_virtual_machine" "template" {
  name                 = var.vsphere_template
  datacenter_id        = data.vsphere_datacenter.IPT.id
}

data "vsphere_datastore" "datastore" {
  name                 = "${var.datastore}"
  datacenter_id        = "${data.vsphere_datacenter.IPT.id}"
}


resource "vsphere_virtual_machine" "Win2019StdCore" {
  
  name                       = "${var.vm_name}"
  num_cpus                   = "${var.vm_cpus}"
  memory                     = var.vm_memory
  folder                     = "${var.vsphere_folder}"
  resource_pool_id           = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id               = data.vsphere_datastore.datastore.id
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  scsi_type                  = data.vsphere_virtual_machine.template.scsi_type
  
  
  disk {
    label                    = "disk0"
    size                     = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned         = false
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  clone {
    template_uuid            = data.vsphere_virtual_machine.template.id
    customize {
      windows_options {
        computer_name        = "${var.vm_name}"
        admin_password       = nonsensitive(data.vault_kv_secret_v2.vcenter.data["password"])
      }
      network_interface {
        ipv4_address         = "${var.ip_address}"
        ipv4_netmask         = "${var.network_mask}"
        
      }
      dns_server_list       = "${var.dns_servers_list}"
      dns_suffix_list        = [ "${var.domain}" ]
      ipv4_gateway           = "${var.vsphere_network_gateway}"
    }
  }
  
}
