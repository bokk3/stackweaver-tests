// outputs
output "team_id" {
  description = "The ID of the created team"
  value       = tfe_team.test_team.id
}

output "team_name" {
  description = "The name of the created team"
  value       = tfe_team.test_team.name
}