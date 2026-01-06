# Test Teams Resource
# This file tests the teams API implementation

resource "tfe_team" "test_team" {
  name         = "test-team"
  organization = var.organization
  visibility   = "organization"
}

// https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/workspace
data "tfe_workspace" "test" {
  name         = "stackweaver-tfe-tests"
  organization = var.organization
}

// https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access#argument-reference
// Test 1: Fixed access level - read
resource "tfe_team_access" "test_team_access_read" {
  access       = "read"
  team_id      = tfe_team.test_team.id
  workspace_id = data.tfe_workspace.test.id
}

// Test 2: Fixed access level - plan
// Note: Requires a separate team and workspace (unique constraint: one access entry per team+workspace)
// Uncomment and create additional team/workspace to test:
/*
resource "tfe_team" "test_team_plan" {
  name         = "test-team-plan"
  organization = var.organization
  visibility   = "organization"
}

resource "tfe_team_access" "test_team_access_plan" {
  access       = "plan"
  team_id      = tfe_team.test_team_plan.id
  workspace_id = data.tfe_workspace.test.id
}
*/

// Test 3: Fixed access level - write
// Note: Requires a separate team and workspace (unique constraint: one access entry per team+workspace)
// Uncomment and create additional team/workspace to test:
/*
resource "tfe_team" "test_team_write" {
  name         = "test-team-write"
  organization = var.organization
  visibility   = "organization"
}

resource "tfe_team_access" "test_team_access_write" {
  access       = "write"
  team_id      = tfe_team.test_team_write.id
  workspace_id = data.tfe_workspace.test.id
}
*/

// Test 4: Fixed access level - admin
// Note: Requires a separate team and workspace (unique constraint: one access entry per team+workspace)
// Uncomment and create additional team/workspace to test:
/*
resource "tfe_team" "test_team_admin" {
  name         = "test-team-admin"
  organization = var.organization
  visibility   = "organization"
}

resource "tfe_team_access" "test_team_access_admin" {
  access       = "admin"
  team_id      = tfe_team.test_team_admin.id
  workspace_id = data.tfe_workspace.test.id
}
*/

// Test 5: Custom permissions - full granular control
// Note: Requires a separate team and workspace (unique constraint: one access entry per team+workspace)
// Uncomment and create additional team/workspace to test:
/*
resource "tfe_team" "test_team_custom" {
  name         = "test-team-custom"
  organization = var.organization
  visibility   = "organization"
}

resource "tfe_team_access" "test_team_access_custom" {
  team_id      = tfe_team.test_team_custom.id
  workspace_id = data.tfe_workspace.test.id

  permissions {
    runs              = "apply"        # Valid: read, plan, apply
    variables         = "write"        # Valid: none, read, write
    state_versions    = "write"        # Valid: none, read, read-outputs, write
    sentinel_mocks    = "read"         # Valid: none, read
    workspace_locking = true           # Boolean
    run_tasks         = true           # Boolean
  }
}
*/

// Test 6: Custom permissions - minimal permissions
// Note: Requires a separate team and workspace (unique constraint: one access entry per team+workspace)
// Uncomment and create additional team/workspace to test:
/*
resource "tfe_team" "test_team_custom_minimal" {
  name         = "test-team-custom-minimal"
  organization = var.organization
  visibility   = "organization"
}

resource "tfe_team_access" "test_team_access_custom_minimal" {
  team_id      = tfe_team.test_team_custom_minimal.id
  workspace_id = data.tfe_workspace.test.id

  permissions {
    runs              = "read"         # Valid: read, plan, apply
    variables         = "none"         # Valid: none, read, write
    state_versions    = "read-outputs" # Valid: none, read, read-outputs, write
    sentinel_mocks    = "none"         # Valid: none, read
    workspace_locking = false          # Boolean
    run_tasks         = false          # Boolean
  }
}
*/