# -----------------------
# basic infra variables
# -----------------------
variable "location" {
  description = "Azure region"
  default     = "Sweden Central"
}

variable "rg_name" {
  description = "Resource group name"
  default     = "ghost-rg"
}

variable "vnet_name" {
  description = "VNet name"
  default     = "ghost-vnet"
}

variable "address_space" {
  description = "VNet CIDR"
  default     = "10.0.0.0/16"
}

variable "subnet_web" {
  description = "Nginx (web) subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "subnet_app" {
  description = "Ghost (app) subnet CIDR"
  default     = "10.0.2.0/24"
}

variable "subnet_db" {
  description = "MySQL (db) subnet CIDR"
  default     = "10.0.3.0/24"
}

# -----------------------
# runtime / compute vars
# -----------------------

# Ghost recommends at least 1 GB memory
variable "vm_size" {
  description = "VM size for all VMs (change per-VM later if needed)"
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin user for VMs"
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key (terraform file() needs an absolute path on some OSes)"
  default     = "~/.ssh/id_rsa.pub"
}
# TODO: public keys to env or key vault

# -----------------------
# static private IPs (makes templating reliable)
# - You can change these as long as they sit inside your subnets above
# -----------------------
variable "ghost_private_ip" {
  description = "Static private IP for Ghost VM (inside subnet_app)"
  type        = string
  default     = "10.0.2.10"
}

variable "mysql_private_ip" {
  description = "Static private IP for MySQL VM (inside subnet_db)"
  type        = string
  default     = "10.0.3.10"
}

# TODO: figure out best practice for private ips

# -----------------------
# sensitive / secrets
# -----------------------
variable "mysql_password" {
  description = "Initial MySQL password (sensitive). Change this before production."
  type        = string
  sensitive   = true
  default     = "mypass" # .tfvars overrides default pass
}

# TODO: key vault
