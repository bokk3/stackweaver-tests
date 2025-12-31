variable "node_name" {
  description = "Proxmox node name where the test resource will be created"
  type        = string
  default     = "pve"
}

variable "iso_url" {
  description = "URL of the ISO file to download"
  type        = string
  default     = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso"
}

variable "iso_filename" {
  description = "Filename for the downloaded ISO"
  type        = string
  default     = "debian-12.9.0-amd64-netinst.iso"
}

variable "acl_path" {
  description = "Proxmox path where the ACL applies (e.g., /vms/100, /storage/local)"
  type        = string
  default     = "/"
}

variable "acl_roles" {
  description = "List of roles to assign in the ACL"
  type        = list(string)
  default     = ["PVEAdmin"]
}

variable "acl_users" {
  description = "List of users to assign the roles to (format: user@realm, e.g., root@pam)"
  type        = list(string)
  default     = ["root@pam"]
}

variable "acl_propagate" {
  description = "Whether the ACL should propagate to sub-paths"
  type        = bool
  default     = false
}

