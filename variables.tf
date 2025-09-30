variable "pve_host" {
  type = string
  description = "Proxmox Virtual Environment Host"
}

variable "pve_hostname" {
  type = string
  description = "Proxmox Virtual Environment Node Hostname"
}

variable "pve_prov_user" {
  type = string
}

variable "pve_vm_count" {
  type = number
}

variable "vm_information" {
  type = list(object({
    template_name   = string
    hostname        = string
    domain          = string
    bridge          = string
    macaddr         = string
    nameserver      = string
    ipconfig0       = string
    state           = string
    tags            = string
    agent           = number
    cpu_cores       = number
    cpu_sockets     = number
    cpu_type        = string
    memory          = number
    scsihw          = string
  }))
  default = [
    {
      template_name = "temp-fedora-38"
      hostname      = "default_hostname"
      domain        = "example.com"
      bridge        = "vmbr1"
      macaddr       = ""
      nameserver    = ""
      ipconfig0     = "ip=dhcp,ip6=auto"
      state         = "running"
      tags          = "inbox"
      agent         = 1
      cpu_cores     = 2
      cpu_sockets   = 1
      cpu_type      = "host"
      memory        = 2048
      scsihw        = "virtio-scsi-pci"
    }
  ]
  description       = "All VM information"
}


variable "base_vmid" {
    type = string
    description = "Base VMID + vm_endex = VMID"
}

variable "ssh_public_key" {
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
