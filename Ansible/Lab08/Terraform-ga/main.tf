#resource "<PROVIDER>_<TYPE>" "<NAME>" {
# [CONFIG …]
#}

#---
# verbinding maken met vSphere
#---
provider "vsphere" {
  user = var.vsphere_user
  password = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = var.vsphere-allow-selfsigned
}

#---
# beschrijving van de vSphere objecten
#---
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name = var.vm_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# templates dat we gaan gebruiken
data "vsphere_virtual_machine" "template" {
  name = "/${var.vsphere_datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_virtual_machine" "template-centos" {
  name = "/${var.vsphere_datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name-centos}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_virtual_machine" "template-windows" {
  name = "/${var.vsphere_datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name-windows}"
}

#---
# maak een Folder
#---
resource "vsphere_folder" "folder" {
  path = "gregory-aernoudt-labo09"
  type = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#---
# maak virtuele machines
#---
resource "vsphere_virtual_machine" "vm" {
  # eigenschappen
  count = var.how_many_machines
  name = "${var.name_prefix}-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id = data.vsphere_datastore.datastore.id
  enable_logging = true
  folder = "gregory-aernoudt-labo09"

  num_cpus = var.vm_cpu
  memory = var.vm_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label = "disk0"
    size = 10
  }

  # clone maken van de template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        domain = var.vm_domain
        host_name = "${var.name_prefix}-${count.index + 1}"
      }
      network_interface {
        ipv4_address = "192.168.50.2${count.index}"
        ipv4_netmask = 24
        dns_server_list = ["192.168.40.1"]
      }
      ipv4_gateway = "192.168.50.1"
    }
  }
}

#---
# maak een windows server
#---
resource "vsphere_virtual_machine" "windows-vm" {
  # eigenschappen
  name = "Windows-ga-server"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id = data.vsphere_datastore.datastore.id
  enable_logging = true
  folder = "gregory-aernoudt-labo09"
  wait_for_guest_ip_timeout = 15

  num_cpus = 2
  memory = 2048
  guest_id = data.vsphere_virtual_machine.template-windows.guest_id
  scsi_type = data.vsphere_virtual_machine.template-windows.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template-windows.network_interface_types[0]
  }

  disk {
    label = "disk0"
    size = 30
  }

  # clone maken van template
  clone {
    template_uuid = data.vsphere_virtual_machine.template-windows.id
    customize {
      windows_options {
        computer_name = "Windows-ga-server"
        admin_password = var.vm_password
        auto_logon = true
      }
      network_interface {
        ipv4_address = "192.168.50.23"
        ipv4_netmask = 24
        dns_server_list = ["192.168.40.1"]
        dns_domain = var.vm_domain
      }
      ipv4_gateway = "192.168.50.1"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../Ansible-ga/inventory.yml ../Ansible-ga/playbook.yml --vault-password-file ../Ansible-ga/passwdfile"
  }
}