terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.118.0"
    }
  }
}

# Upload the rendered cloud-init user data as a snippet (the provider uses SSH for this)
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.node_name

  source_raw {
    data      = templatefile("${path.module}/cloud-inits/cloud-init_gen.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.hostname, domain = var.domain })
    file_name = "user_data_vm-${var.hostname}.yml"
  }
}


resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.hostname
  node_name = var.node_name
  vm_id     = var.vm_id
  tags      = sort(var.tags)

  started = var.started
  on_boot = var.on_boot

  # Template to clone this vm from (created with ./scripts/create_template.sh)
  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = var.agent
  }

  cpu {
    cores   = var.cpu_cores
    sockets = var.cpu_sockets
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  scsi_hardware = var.scsihw

  # The size has to be at least as big as the disk in the template
  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    size         = var.disk_size
  }

  network_device {
    bridge      = var.net_bridge
    model       = var.net_model
    vlan_id     = var.net_vlan_id
    mac_address = var.net_macaddr
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.storage

    ip_config {
      # CIDR notation (e.g. 10.0.0.10/24) or "dhcp"; omitted when null
      dynamic "ipv4" {
        for_each = var.ip_address == null ? [] : [1]
        content {
          address = var.ip_address
          gateway = var.gateway
        }
      }

      # CIDR notation, "auto" (SLAAC) or "dhcp"; omitted when null
      dynamic "ipv6" {
        for_each = var.ipv6_address == null ? [] : [1]
        content {
          address = var.ipv6_address
          gateway = var.ipv6_gateway
        }
      }
    }

    dns {
      domain  = var.domain
      servers = var.nameservers
    }

    # User, SSH key and packages come from this snippet
    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }
}
