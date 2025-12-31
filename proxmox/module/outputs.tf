output "proxmox_version" {
  description = "Proxmox version information"
  value       = data.proxmox_virtual_environment_version.version
}

output "apt_repository_id" {
  description = "ID of the configured APT repository"
  value       = proxmox_virtual_environment_apt_repository.test_repo.id
}

output "iso_file_path" {
  description = "Path to the downloaded ISO file"
  value       = proxmox_virtual_environment_download_file.test_iso.id
}

output "acl_id" {
  description = "ID of the created ACL"
  value       = proxmox_virtual_environment_acl.test_acl.id
}

