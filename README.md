# tf-mod-pve

OpenTofu/Terraform module that creates one VM on a Proxmox VE node by cloning a cloud-init template.

For each VM the module:

1. Renders a cloud-init user-data file from `cloud-inits/cloud-init_gen.cloud_config.tftpl`.
2. Copies it over SSH to `/var/lib/vz/snippets/` on the Proxmox host.
3. Clones the template and attaches that file as cloud-init user data (`cicustom`).

The VM gets a user `admin` (passwordless sudo, your SSH key) and `qemu-guest-agent`. After the agent is running, `curl`, `vim`, `htop` and `bash-completion` are installed and the system is upgraded (apt or dnf).

## Requirements

- OpenTofu or Terraform.
- Provider `telmate/proxmox` `3.0.2-rc04`, configured in your root module (the module does not configure it).
- A Proxmox API token for the provider.
- SSH access to the Proxmox host with a user that can write to `/var/lib/vz/snippets` (usually `root`).
- The `local` storage must allow the content type **Snippets** (Datacenter → Storage → local → Content).
- A cloud-init template on the node (see below).

## 1. Create templates

Run [`scripts/create_template.sh`](./scripts/create_template.sh) as root on the Proxmox host. Before running it:

- Set `ssh_keyfile`, `username` and `storage` near the bottom of the script.
- Comment in/out the images you want. Each one becomes a template with a fixed VMID and name, e.g. `902` / `temp-debian-12`.

The script fails for templates whose VMID already exists.

## 2. Use the module

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url          # e.g. https://pve.example.com:8006/api2/json
  pm_api_token_id     = var.proxmox_api_token_id     # e.g. terraform@pve!tofu
  pm_api_token_secret = var.proxmox_api_token_secret
}

module "web01" {
  source = "git::https://github.com/CubelaPetar/tofu-module_deploy-pve-vm.git"

  # Proxmox access
  pve_host        = "192.168.1.10"  # SSH target for the snippet upload
  pve_hostname    = "pve"           # node name as shown in the cluster
  pve_prov_user   = "root"
  ssh_public_key  = file("~/.ssh/id_ed25519.pub")
  ssh_private_key = file("~/.ssh/id_ed25519")

  # VM
  hostname      = "web01"
  domain        = "example.com"
  template_name = "temp-debian-12"
  base_vmid     = 1000
  vm_id         = 1               # VMID = 1001
  state         = "running"
  tags          = "web;debian"
  boot          = "order=scsi0"

  cpu_cores = 2
  memory    = 2048
  scsihw    = "virtio-scsi-pci"
  storage   = "local-zfs"
  disk_size = "16G"               # must be >= the template disk

  # Network
  net_bridge  = "vmbr0"
  net_macaddr = "BC:24:11:00:00:01"                  # optional
  ipconfig0   = "ip=192.168.1.51/24,gw=192.168.1.1"  # or "ip=dhcp"
  nameserver  = "192.168.1.1"
}
```

To create several VMs, use `for_each` over a map of VM settings.

## Inputs

| Name | Default | Description |
|---|---|---|
| `pve_host` | – | Address used to SSH into the Proxmox host |
| `pve_hostname` | – | Proxmox node name (`target_node`) |
| `pve_prov_user` | – | SSH user on the Proxmox host |
| `ssh_public_key` | – | Public key added to the VM user `admin` |
| `ssh_private_key` | – | Private key used to SSH into the Proxmox host |
| `hostname`, `domain` | – | VM hostname and domain (FQDN = `hostname.domain`) |
| `template_name` | – | Template to clone |
| `base_vmid`, `vm_id` | – | VMID = `base_vmid + vm_id` |
| `state` | – | `running` or `stopped` |
| `tags` | – | Proxmox tags, separated by `;` |
| `boot` | – | Boot order, e.g. `order=scsi0` |
| `cpu_type` / `cpu_cores` / `cpu_sockets` | `host` / `2` / `1` | CPU |
| `memory` | – | RAM in MB |
| `scsihw` | – | SCSI controller, e.g. `virtio-scsi-pci` |
| `storage` | – | Storage for the disk and the cloud-init drive |
| `disk_size` | – | Disk size, e.g. `16G` |
| `net_id` / `net_model` | `0` / `virtio` | Network device |
| `net_bridge` | – | Bridge, e.g. `vmbr0` |
| `net_macaddr` | `null` | MAC address of the NIC (uppercase). `null` lets Proxmox generate one |
| `ipconfig0` | – | Cloud-init IP config, e.g. `ip=dhcp` |
| `nameserver` | – | DNS server |
| `agent` | `1` | Enable the QEMU guest agent option in Proxmox |
