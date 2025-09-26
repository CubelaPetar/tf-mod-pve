variable "vm_tags-00" {
    type = list(string)
}

variable "vm_tags-01" {
    type = list(string)
}

#variable "vm_tags-02" {
#    type = list(string)
#}

variable "pve_host" {
  type = string
}

variable "pve_prov_user" {
  type = string
}

variable "pve_vm_count" {
  type = string
}

variable "pve_temp_name" {
  type = list(string)
}

variable "vm_hostnames" {
    type = list(string)
}

variable "vm_bridge" {

    type = list(string)
}

variable "vm_macaddr" {

    type = list(string)
}

variable "vm_nameserver" {
    type = list(string)
}


variable "base_vmid" {
    type = string
}

variable "public_ssh_key" {
  type = string 
  sensitive = true
}

variable "ssh_private_key" {
  type = string 
  sensitive = true
}

#variable "working_directory" {
#  type = string
#}
