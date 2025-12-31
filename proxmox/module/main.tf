# Simple data source to test Proxmox connectivity
data "proxmox_virtual_environment_version" "version" {}

# Download an ISO file to the local datastore
# This resource downloads files from a URL to a Proxmox datastore
# The datastore must have at least 10GB free space
# Reference: https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "test_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node_name
  url          = var.iso_url
  file_name    = var.iso_filename

  # Optional: Verify the download (set to true to verify checksums if available)
  verify = false
}

# Test resource: Create an ACL (Access Control List) for testing
# This resource manages permissions for users or groups on specific paths
# Reference: https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_acl
resource "proxmox_virtual_environment_acl" "test_acl" {
  path      = var.acl_path
  role_id   = var.acl_role_id
  user_id   = var.acl_user_id
  propagate = var.acl_propagate
}