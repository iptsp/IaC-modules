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

data "vault_approle_auth_backend_role_id" "terraform" {
  backend   = "approle"
  role_name = "terraform"
}

resource "vault_approle_auth_backend_login" "login" {
  backend   = "approle"
  role_id   = var.role_id
  
}

#Reading vmware secret

data "vault_kv_secret_v2" "vcenter" {
  mount         = "vmware"
  name          = "vcenter"
}

data "vault_kv_secret_v2" "linux_credentials" {
  mount         = "servers"
  name          = "linux/build" 
}


resource "local_file" "hosts" {
  content = templatefile("${path.module}/templates/hosts.tpl",
  {
    vm_name       = "${var.vm_name}"
    ansible_user  = nonsensitive(data.vault_kv_secret_v2.linux_credentials.data["ssh_user"])
    ansible_pass  = nonsensitive(data.vault_kv_secret_v2.linux_credentials.data["ssh_password"])
    ip_address    = "${var.ip_address}"
  }
  )

  filename        = "${path.module}/ansible/inventario/hosts" 
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


resource "vsphere_virtual_machine" "ubuntu2204" {
  
  name                       = "${var.vm_name}"
  num_cpus                   = "${var.vm_cpus}"
  memory                     = var.vm_memory
  folder                     = "${var.vsphere_folder}"
  resource_pool_id           = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id               = data.vsphere_datastore.datastore.id
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  
  
  disk {
    label                    = "disk0"
    size                     = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned         = true
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  clone {
    template_uuid            = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name            = "${var.vm_name}"
        domain               = "${var.domain}"
      }
      network_interface {
        ipv4_address         = "${var.ip_address}"
        ipv4_netmask         = "${var.cidr}"
        
      }
      dns_server_list        = "${var.dns_servers_list}"
      dns_suffix_list        = [ "${var.domain}" ]
      ipv4_gateway           = "${var.vsphere_network_gateway}"
    }
  }

  
  provisioner "local-exec" {
    command = "cd ansible && sleep 300 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook main.yml -i inventario/hosts -e \"sudo_new_user=${var.sudo_new_user} sudo_new_pass=${var.new_user_pass}\" -vvvv"
    interpreter = ["/bin/bash", "-c"]
  }


}