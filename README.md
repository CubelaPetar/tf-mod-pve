# TF-Mod-PVE

Terraform/OpenTofu module to create VMs via cloud-init on a Proxmox Virtual Environement host.

Before using this module the templates one whishes to use have to be created on the pve host. 
This can be achieved using the bash [script](./scripts/create_template.sh). 

## Usage 

Use the module:

```terraform
module "pve_vms" {
  source                    = "./modules/pve_deploy_vms"

  for_each                  = var.vm

  hostname                  = each.key
  template_name             = each.value.template_name
  domain                    = each.value.domain
  nameserver                = each.value.nameserver 
  ipconfig0                 = each.value.ipconfig0 
  state                     = each.value.state 
  tags                      = each.value.tags 
  memory                    = each.value.memory 
  scsihw                    = each.value.scsihw
  storage                   = each.value.storage  
  boot                      = each.value.boot

  net_id                    = each.value.net.id
  net_model                 = each.value.net.model
  net_bridge                = each.value.net.bridge
  net_macaddr               = each.value.net.macaddr

  cpu_type                  = each.value.cpu.type
  cpu_cores                 = each.value.cpu.cores
  cpu_sockets               = each.value.cpu.sockets
 
  # general
  pve_host                  = var.pve_host
  pve_hostname              = var.pve_hostname
  pve_prov_user             = var.pve_prov_user

  proxmox_api_url           = var.proxmox_api_url
  proxmox_api_token_id      = var.proxmox_api_token_id
  proxmox_api_token_secret  = var.proxmox_api_token_secret

  base_vmid                 = var.base_vmid
  vm_id                     = each.value.vm_id

  ssh_public_key            = var.ssh_public_key
  ssh_private_key           = var.ssh_private_key

}
```

Required variable definitions

```terraform
variable "vm" {
  type = map(object({
    vm_id           = number
    template_name   = string
    domain          = string 
    net             = object({
      id          = number 
      model       = string
      bridge      = string 
      macaddr     = string
    })
    nameserver      = string 
    ipconfig0       = string 
    state           = string 
    tags            = string 
    memory          = number 
    scsihw          = string
    boot            = string
    storage         = string
    cpu             = object({
      type    = string
      cores   = number
      sockets = number
    })
  }))
}  
```

## Dependancies

This module has a dependency on the ```e-breuninger/netbox``` provider.


