variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}


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
  description = "User on PVE having permissions to access /var/lib/vz/snippets"
}

## deprecated
#variable "pve_vm_count" {
#  type = number
#
#}

variable "vm_id" {
  type = number 
  description = "Index for the VM such that the vmid = base_vmid + vm_id"
}

variable "template_name" {
  type = string
  description = "Name of the used template. Has to be created with ./scripts/create_template.sh"
}

variable "hostname" {
  type = string
  description = "Hostname of the VM"
}

variable "domain" {
  type = string
  description = "Domain of the VM"
}

variable "net_id" {
  type = number
  description = "network id?"
  default = 0
}

variable "net_model" {
  type = string 
  default = "virtio"
}

variable "net_bridge" {
  type = string
  description = "Network bridge interface"
}

variable "net_macaddr" {
  type = string
  description = "VMs mac address"
}

#variable "cpu" {
#  type = object({
#    cpu_type = string
#    cpu_cores = number 
#    cpu_sockets = number
#  })
#  default = {
#    cpu_type = "host"
#    cpu_cores = 2
#    cpu_sockets = 1
#  }
#  description = "CPU config of VM"
#}

variable "cpu_type" {
  type        = string
  description = "Type of CPU"
  default     = "host"
}

variable "cpu_cores" {
  type        = number
  description = "Number uf cores" 
  default     = 2
}

variable "cpu_sockets" {
  type        = number
  description = "Number of CPU sockets"
  default     = 1
}

variable "nameserver" {
  type = string
}

variable "ipconfig0" {
  type = string
}

variable "state" {
  type = string
} 

variable "tags" {
  type = string
}

variable "agent" {
  type = number
  description = "Should qemu agent be enabled in pve"
  default = 1
}

variable "boot" {
  type = string
  description = "Boot options"
}

variable "memory" {
  type = number
}

variable "scsihw" {
  type = string
}

variable "storage" {
  type = string
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

