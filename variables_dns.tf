# opentofu/dns provider
variable "tsig-key" { 
  type = string
  sensitive = true
} 

variable "zones" {
  type = list(string)
}

