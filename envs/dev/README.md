# Dev Environment - Deprecated Resource Test

This workspace is used to test deprecation warning detection in StackWeaver.

## Purpose

This workspace contains Terraform resources with deprecated attributes to verify that:
1. Deprecation warnings are properly detected from Terraform plan JSON output
2. Warnings are displayed in the UI with proper styling (orange badges for deprecations)
3. The warning parsing correctly identifies deprecation vs regular warnings

## Deprecated Resource

The `aws_instance` resource uses the deprecated `associate_public_ip_address` attribute, which has been replaced with `network_interface` blocks. This will generate a deprecation warning when running `terraform plan`.

## Testing

1. Create a workspace in StackWeaver pointing to this directory (`envs/dev`)
2. Run a plan operation
3. Verify that deprecation warnings appear in the warnings banner
4. Verify that deprecation warnings have orange styling (vs yellow for regular warnings)

