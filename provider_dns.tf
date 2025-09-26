terraform {
  required_providers {
    dns     = {
      source    = "opentofu/dns"
      version   = "3.4.3"
    }
  }
}

# Configure the DNS Provider
provider "dns" {
  update {
    #server        = "dns0.pnx.lan"
    server        = var.dns_server
    key_name      = "tsig-key."
    key_algorithm = "hmac-sha256"
    key_secret    = var.tsig-key
  }
}
