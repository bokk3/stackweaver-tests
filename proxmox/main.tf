# Simple data source to test Proxmox connectivity - using version for simplicity
data "proxmox_virtual_environment_version" "version" {}

# Output the version to verify it works
output "proxmox_version" {
  value = data.proxmox_virtual_environment_version.version
}
