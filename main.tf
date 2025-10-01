
terraform {
  required_providers {
    proxmox = {
      source    = "telmate/proxmox"
      version   = "3.0.2-rc04"
    }
  }
}

# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "cloud_init_user_data_file" {
  ##count     = var.pve_vm_count
  #content   = templatefile("${var.working_directory}/cloud-inits/cloud_init_fedora42_ipa_clients.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.hostname_vms[0] , domain = var.domain })
  content   = templatefile("${path.module}/cloud-inits/cloud-init_gen.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.hostname , domain = var.domain })
  filename  = "${path.module}/files/user_data_vm-${var.hostname}.cfg"
}


# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_config_file" {
  connection {
    type          = "ssh"
    user          = var.pve_prov_user
    private_key   = var.ssh_private_key
    host          = var.pve_host
  }

  provisioner "file" {
    source        = local_file.cloud_init_user_data_file.filename
    destination   = "/var/lib/vz/snippets/user_data_vm-${var.hostname}.yml"
  }
}


resource "proxmox_vm_qemu" "vm" {
    name        = var.hostname

    depends_on = [
      null_resource.cloud_init_config_file
    ]

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = var.pve_hostname

    # The template name to clone this vm from
    clone = var.template_name

    # Activate QEMU agent for this VM
    agent = var.agent

    #pool = linux
    os_type     = "cloud-init"

    vmid        = "${var.base_vmid}" + "${var.vm_id}" 

    vm_state    = var.state
    
    cpu {
          cores   = var.cpu_cores
          sockets = var.cpu_sockets
          type    = var.cpu_type
    }
    memory      = var.memory
    scsihw      = var.scsihw

    # Setup the disk
    disks {
      scsi {
        scsi0 {
          # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
          disk {
            storage = var.storage
            # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
            size    = "16G" 
          }
        }
      }
      ide {
        # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
        ide1 {
          cloudinit {
            storage = var.storage
          }
        }
      }
    }    
    # Setup the network interface and assign a vlan tag: 256

    network {
      id        = var.net_id
      model     = var.net_model
      bridge    = var.net_bridge
      macaddr   = var.net_macaddr
    }

    nameserver = var.nameserver

    onboot = true
  #boot = "order=scsi0"
    boot = var.boot
    tags = var.tags

    # Setup the ip address using cloud-init.
    # Keep in mind to use the CIDR notation for the ip.
    #ipconfig0   = "ip=10.11.12.65/24,gw=10.11.12.254"
    ipconfig0   = var.ipconfig0
    ciuser      = var.pve_prov_user
    cicustom    = "user=local:snippets/user_data_vm-${var.hostname}.yml" 
    ciupgrade   = true

    sshkeys     = var.ssh_public_key
}
