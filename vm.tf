# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "cloud_init_user_data_file" {
  count     = var.pve_vm_count
  #content   = templatefile("${var.working_directory}/cloud-inits/cloud_init_fedora42_ipa_clients.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.hostname_vms[0] , domain = var.domain })
  content   = templatefile("${path.module}/cloud-inits/cloud-init_gen.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.vm_hostnames[cound.index] , domain = var.domain })
  filename  = "${path.module}/files/user_data_vm-${count.index}.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_config_files" {
  count           = var.pve_vm_count
  connection {
    type          = "ssh"
    user          = var.pve_prov_user
    private_key   = var.ssh_private_key
    host          = var.pve_host
  }

  provisioner "file" {
    source        = local_file.cloud_init_user_data_file[count.index].filename
    destination   = "/var/lib/vz/snippets/user_data_vm-${count.index}.yml"
  }
}


resource "proxmox_vm_qemu" "vms" {
    count       = var.pve_vm_count
    name        = var.vm_hostnames[count.index]

    depends_on = [
      null_resource.cloud_init_config_files
    ]

    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = var.pve_host

    # The template name to clone this vm from
    clone = var.pve_temp_name

    # Activate QEMU agent for this VM
    agent = 1

    #pool = linux

    os_type = "cloud-init"
    vmid = "${var.base_vmid}" + "${count.index}"
    vm_state = "running"
    
    cpu {
        cores = 2
        sockets = 1
        type = "host"
    }
    memory      = 2048
    scsihw      = "virtio-scsi-pci"

    # Setup the disk
    disks {
      scsi {
        scsi0 {
          # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
          disk {
            storage = "local-lvm"
            # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
            size    = "16G" 
          }
        }
      }
      ide {
        # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
        ide1 {
          cloudinit {
            storage = "local-lvm"
          }
        }
      }
    }    
    # Setup the network interface and assign a vlan tag: 256

    network {
        id = 0
        model = "virtio"
        bridge = var.vm_bridge[count.index]
        macaddr   = var.vm_macaddr[count.index]
    }
    nameserver = var.vm_nameserver[count.index]

    onboot = true
    boot = "order=scsi0"
  #tags = "ldap,samba,kerberos,dns,pki"
    tags = "${var.vm_tags}-${count.index}"

    # Setup the ip address using cloud-init.
    # Keep in mind to use the CIDR notation for the ip.
    #ipconfig0   = "ip=10.11.12.65/24,gw=10.11.12.254"
    ipconfig0   = var.vm_ipconfig0[count.index]
    ciuser      = var.prov_user
    cicustom    = "user=local:snippets/user_data_vm-${count.index}.yml" 
    ciupgrade   = true

    sshkeys     = var.ssh_public_key
}
