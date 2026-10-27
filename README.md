# tf-mod-pve

OpenTofu/Terraform module that creates one VM on a Proxmox VE node by cloning a cloud-init template.

For each VM the module:

1. Renders a cloud-init user-data file from `cloud-inits/cloud-init_gen.cloud_config.tftpl` and uploads it as a snippet.
2. Clones the template and attaches that snippet as cloud-init user data.

The VM gets a user `admin` (passwordless sudo, your SSH key) and `qemu-guest-agent`. After the agent is running, `curl`, `vim`, `htop` and `bash-completion` are installed and the system is upgraded (apt or dnf).

## Requirements

- OpenTofu or Terraform.
- Provider [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) `>= 0.118.0` with an API token and an `ssh` block, configured in your root module (the module does not configure it). The provider uses SSH to upload the snippet.
- Proxmox VE 9.x.
- A datastore that allows the content type **Snippets** (default `local`: Datacenter → Storage → local → Content).
- A cloud-init template on the node (see below).

SSH as `root` works without further setup. A non-root SSH user needs these sudoers rules on the node ([provider docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-user)):

```text
admin ALL=(root) NOPASSWD: /usr/sbin/pvesm apiinfo
admin ALL=(root) NOPASSWD: /usr/bin/tee ^/var/lib/vz/snippets/[a-zA-Z0-9_][a-zA-Z0-9_.-]*$
```

## 1. Create templates

Run [`scripts/create_template.sh`](./scripts/create_template.sh) as root on the Proxmox host. Before running it:

- Set `ssh_keyfile`, `username` and `storage` near the bottom of the script.
- Comment in/out the images you want. Each one becomes a template with a fixed VMID and name, e.g. `903` / `temp-debian-13`.

The script fails for templates whose VMID already exists.

## 2. Use the module

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint   # e.g. https://192.168.1.10:8006/
  api_token = var.proxmox_api_token  # e.g. tofu@pve!tofu=<secret>
  insecure  = true                   # self-signed certificate

  ssh {
    agent    = true                  # key from your ssh-agent
    username = "admin"
  }
}

module "web01" {
  source = "git::https://github.com/CubelaPetar/tf-mod-pve.git?ref=v1.0.0"

  node_name      = "pve"            # node name as shown in the cluster
  vm_id          = 1001
  template_vm_id = 903              # temp-debian-13
  hostname       = "web01"
  domain         = "example.com"
  tags           = ["web", "debian"]
  ssh_public_key = file("~/.ssh/id_ed25519.pub")

  memory    = 2048
  storage   = "local-lvm"
  disk_size = 16                    # GB, must be >= the template disk

  net_bridge  = "vmbr0"
  ip_address  = "192.168.1.51/24"   # or "dhcp"
  gateway     = "192.168.1.1"
  nameservers = ["192.168.1.1"]
}
```

To create several VMs, use `for_each` over a map of VM settings.

## Inputs

| Name | Default | Description |
|---|---|---|
| `node_name` | – | Proxmox node name |
| `snippets_datastore` | `local` | Datastore for the cloud-init snippet |
| `vm_id` | – | VMID of the new VM |
| `template_vm_id` | – | VMID of the template to clone |
| `hostname`, `domain` | – | VM hostname and domain (FQDN = `hostname.domain`) |
| `tags` | `[]` | Proxmox tags |
| `started` / `on_boot` | `true` / `true` | VM running / start on node boot |
| `agent` | `true` | Enable the QEMU guest agent option in Proxmox |
| `cpu_type` / `cpu_cores` / `cpu_sockets` | `host` / `2` / `1` | CPU |
| `memory` | – | RAM in MB |
| `scsihw` | `virtio-scsi-pci` | SCSI controller |
| `storage` | – | Datastore for the disk and the cloud-init drive |
| `disk_size` | – | Disk size in GB |
| `net_bridge` | – | Bridge, e.g. `vmbr0` |
| `net_model` | `virtio` | NIC model |
| `net_macaddr` | `null` | MAC address of the NIC. `null` lets Proxmox generate one |
| `ip_address` | – | IPv4 address in CIDR notation or `dhcp` |
| `gateway` | `null` | IPv4 gateway |
| `nameservers` | – | DNS servers |
| `ssh_public_key` | – | Public key added to the VM user `admin` |
