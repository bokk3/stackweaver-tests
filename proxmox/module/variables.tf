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

variable "acl_role_id" {
  description = "Role ID to assign in the ACL (e.g., Administrator, PVEAdmin)"
  type        = string
  default     = "PVEAdmin"
}

variable "acl_user_id" {
  description = "User ID to assign the role to (format: user@realm, e.g., root@pam)"
  type        = string
  default     = "root@pam"
}

variable "acl_propagate" {
  description = "Whether the ACL should propagate to sub-paths"
  type        = bool
  default     = false
}

