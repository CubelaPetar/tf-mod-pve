# opentofu/dns provider
variable "tsig-key" { 
  type = string
  sensitive = true
} 

variable "dns_server" {
  type = string
}

variable "zones" {
  type = list(string)
}

