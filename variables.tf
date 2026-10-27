variable "node_name" {
  type        = string
  description = "Proxmox node name as shown in the cluster"
}

variable "snippets_datastore" {
  type        = string
  description = "Datastore with content type 'snippets' for the cloud-init user data"
  default     = "local"
}

variable "vm_id" {
  type        = number
  description = "VMID of the new VM"
}

variable "template_vm_id" {
  type        = number
  description = "VMID of the template to clone. Has to be created with ./scripts/create_template.sh"
}

variable "hostname" {
  type        = string
  description = "Hostname of the VM"
}

variable "domain" {
  type        = string
  description = "Domain of the VM"
}

variable "tags" {
  type        = list(string)
  description = "Proxmox tags"
  default     = []
}

variable "started" {
  type        = bool
  description = "Whether the VM is running"
  default     = true
}

variable "on_boot" {
  type        = bool
  description = "Start the VM when the node boots"
  default     = true
}

variable "agent" {
  type        = bool
  description = "Enable the QEMU guest agent option in Proxmox"
  default     = true
}

variable "cpu_type" {
  type        = string
  description = "Type of CPU"
  default     = "host"
}

variable "cpu_cores" {
  type        = number
  description = "Number of cores"
  default     = 2
}

variable "cpu_sockets" {
  type        = number
  description = "Number of CPU sockets"
  default     = 1
}

variable "memory" {
  type        = number
  description = "RAM in MB"
}

variable "scsihw" {
  type        = string
  description = "SCSI controller"
  default     = "virtio-scsi-pci"
}

variable "storage" {
  type        = string
  description = "Datastore for the disk and the cloud-init drive"
}

variable "disk_size" {
  type        = number
  description = "Disk size in GB"
}

variable "net_bridge" {
  type        = string
  description = "Network bridge interface"
}

variable "net_model" {
  type    = string
  default = "virtio"
}

variable "net_macaddr" {
  type        = string
  description = "MAC address of the NIC. Null lets Proxmox generate one"
  default     = null
}

variable "ip_address" {
  type        = string
  description = "IPv4 address in CIDR notation or \"dhcp\""
}

variable "gateway" {
  type        = string
  description = "IPv4 gateway. Null when ip_address is dhcp"
  default     = null
}

variable "nameservers" {
  type        = list(string)
  description = "DNS servers"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key added to the VM user admin"
}
