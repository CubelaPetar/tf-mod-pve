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
  description = "Proxmox Virtual Environment Host"
}

variable "pve_prov_user" {
  type = string
}

variable "pve_vm_count" {
  type = string
}

variable "vm_information" {
  type = list(object({
    template_name   = string
    hostname        = string
    bridge          = string
    macaddr         = string
    nameserver      = string
    ipconfig0       = string
    state           = string
  }))
  default = [
    {
      template_name = "temp-fedora-38"
      ipconfig0     = "ip=dhcp,ip6=auto"
      state         = "running"
    }
  ]
  description       = "All VM information"
}


variable "base_vmid" {
    type = string
    description = "Base VMID + vm_endex = VMID"
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
