
variable vsphere_user {
  type = string
  default = "administrator@vsphere.local"
}

variable vsphere_password {
  type = string
  default = "P@ssw0rd"
}

variable vsphere_server {
  type = string
  default = "192.168.50.10"
}

variable vsphere-allow-selfsigned {
  type = bool
  default = true
}

variable vsphere_datacenter {
  type = string
  default = "Lab"
}

variable vm_datastore {
  type = string
  default = "scsi-student"
}

variable vsphere_cluster {
  type = string
  default = "DRS-Cluster"
}

variable vm_network {
  type = string
  default = "VM Network"
}

variable "vsphere-template-folder" {
  type = string
  description = "Template folder"
  default = "templates"
}

variable "vm-template-name" {
  type = string
  description = "template for creating a VM"
  default = "ubuntu-template"
}
variable "vm-template-name-centos" {
  type = string
  description = "template for creating a Centos VM"
  default = "centos-template"
}
variable "vm-template-name-windows" {
  type = string
  description = "template for creating a Windows VM"
  default = "win-template"
}

variable how_many_machines {
  description = "aantal machines we willen gaan bepalen bij default"
  type  = number
  default = 3
}

variable vm_cpu {
  type  = number
  default = 1
}

variable vm_ram {
  type  = number
  default = 1024
}

variable vm_domain {
  type = string
  default = "howest.local"
}

variable name_prefix{
  type = string
  description = "voorvoegsel bepaald bij default"
  default = "ga-server"
}

variable how_many_loadbalancers {
  description = "aantal machines we willen gaan bepalen bij default"
  type  = number
  default = 1
}

variable vm_password{
  type = string
  default = "P@ssw0rd"
}

