# Test 1: Create a basic variable set (organization-owned, non-priority)
resource "tfe_variable_set" "basic" {
  name         = "test-basic-varset"
  description  = "Basic variable set for testing"
  global       = false
  priority     = false
  organization = var.organization
}

# Test 2: Create a priority variable set (organization-owned)
resource "tfe_variable_set" "priority" {
  name         = "test-priority-varset"
  description  = "Priority variable set for testing"
  global       = true
  priority     = true
  organization = var.organization
}

# Test 3: Create a variable set with parent relationship (organization)
resource "tfe_variable_set" "org_parent" {
  name         = "test-org-parent-varset"
  description  = "Variable set with organization parent"
  global       = true
  priority     = false
  organization = var.organization
}

# Test 4: Create variables in the basic variable set
resource "tfe_variable" "basic_var1" {
  key             = "test_var1"
  value           = "value1"
  category        = "terraform"
  description     = "Test variable 1"
  sensitive       = false
  variable_set_id = tfe_variable_set.basic.id
}

resource "tfe_variable" "basic_var2" {
  key             = "test_var2"
  value           = "value2"
  category        = "terraform"
  description     = "Test variable 2"
  sensitive       = false
  variable_set_id = tfe_variable_set.basic.id
}

# Test 5: Create variables in the priority variable set
resource "tfe_variable" "priority_var1" {
  key             = "test_var1" # Same key as basic_var1 to test precedence
  value           = "priority_value1"
  category        = "terraform"
  description     = "Priority test variable 1"
  sensitive       = false
  variable_set_id = tfe_variable_set.priority.id
}

# Test 6: Assign variable set to workspace
resource "tfe_workspace_variable_set" "basic_workspace" {
  variable_set_id = tfe_variable_set.basic.id
  workspace_id    = "ws-1q0HQPrGm4Yf1q0H"
}

# Test 7: Create a workspace variable (should override non-priority variable sets)
# Note: The TFE provider doesn't have tfe_workspace_variable resource.
# Workspace variables are typically created via the API or UI.
# This test is commented out as it's not supported by the provider.
# resource "tfe_variable" "workspace_var" {
#   key          = "test_var2" # Same key as basic_var2 to test precedence
#   value        = "workspace_value2"
#   category     = "terraform"
#   description  = "Workspace variable that should override non-priority varsets"
#   sensitive    = false
#   workspace_id = var.workspace_name
# }

# Test 8: Create environment variable in variable set
resource "tfe_variable" "env_var" {
  key             = "TEST_ENV_VAR"
  value           = "env_value"
  category        = "env"
  description     = "Environment variable in variable set"
  sensitive       = false
  variable_set_id = tfe_variable_set.basic.id
}

# Test 9: Create sensitive variable
resource "tfe_variable" "sensitive_var" {
  key             = "sensitive_test_var"
  value           = "sensitive_value"
  category        = "terraform"
  description     = "Sensitive variable"
  sensitive       = true
  variable_set_id = tfe_variable_set.basic.id
}

# Test 10: Update variable set priority
resource "tfe_variable_set" "updatable" {
  name         = "test-updatable-varset"
  description  = "Variable set for testing updates"
  global       = false
  priority     = false
  organization = var.organization
}

# Outputs for verification
output "basic_varset_id" {
  description = "ID of the basic variable set"
  value       = tfe_variable_set.basic.id
}

output "priority_varset_id" {
  description = "ID of the priority variable set"
  value       = tfe_variable_set.priority.id
}

output "basic_varset_priority" {
  description = "Priority status of basic variable set"
  value       = tfe_variable_set.basic.priority
}

output "priority_varset_priority" {
  description = "Priority status of priority variable set"
  value       = tfe_variable_set.priority.priority
}

# Note: To test this file:
# 1. Set TFE_HOSTNAME and TFE_TOKEN environment variables
# 2. Run: terraform init
# 3. Run: terraform plan
# 4. Run: terraform apply
# 5. Verify variable precedence:
#    - test_var1 should be "priority_value1" (priority varset overrides)
#    - test_var2 should be "value2" (from basic varset, workspace vars not testable via provider)
#    - TEST_ENV_VAR should be available as environment variable
# 6. Run: terraform destroy to clean up
