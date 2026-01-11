# StackWeaver Workflow Templates

This directory contains workflow templates for testing StackWeaver's workflow orchestration capabilities.

## What are Workflow Templates?

Workflow templates allow you to define multi-step deployment processes that can:
- Chain multiple Ansible playbooks
- Combine Terraform and Ansible operations
- Define conditional execution paths
- Set up notifications
- Configure timeouts and retries

## Available Workflows

### `elasticsearch-deployment.yml`

A comprehensive workflow that deploys the Elastic Stack (Elasticsearch, Logstash, Kibana) on Arch Linux.

**Steps:**
1. **Validate Environment** - Checks prerequisites
2. **Deploy Elasticsearch** - Runs the elasticsearch.yml playbook
3. **Verify Services** - Confirms services are running
4. **Troubleshoot Services** (optional) - Debugging step
5. **Cleanup on Failure** - Rollback on errors

## Testing Workflow Templates

### Prerequisites

1. **StackWeaver API running**
   - Default: `localhost:8022`
   - Set via `STACKWEAVER_HOST` environment variable

2. **Authentication Token**
   ```bash
   export TFE_TOKEN="your-api-token-here"
   ```

3. **Organization Access**
   - Ensure you have access to the target organization
   - Set via `ORG_NAME` environment variable or pass as argument

### Quick Start

```bash
# Basic test (validate and create workflow)
./test-workflow.sh workflows/elasticsearch-deployment.yml my-org

# Test with specific workflow ID (to execute)
./test-workflow.sh workflows/elasticsearch-deployment.yml my-org <workflow-id>
```

### Manual Testing Steps

#### 1. Validate Workflow YAML

```bash
# Using yamllint (if installed)
yamllint workflows/elasticsearch-deployment.yml

# Using Python
python3 -c "import yaml; yaml.safe_load(open('workflows/elasticsearch-deployment.yml'))"
```

#### 2. Check API Connectivity

```bash
export TFE_TOKEN="your-token"
export STACKWEAVER_HOST="localhost:8022"

curl -H "Authorization: Bearer $TFE_TOKEN" \
  "http://${STACKWEAVER_HOST}/api/v2/ping"
```

#### 3. Create Workflow Template via API

```bash
# Convert YAML to JSON (requires PyYAML)
WORKFLOW_JSON=$(python3 -c "
import sys, yaml, json
with open('workflows/elasticsearch-deployment.yml') as f:
    data = yaml.safe_load(f)
    print(json.dumps(data))
")

# Create workflow template
curl -X POST \
  -H "Authorization: Bearer $TFE_TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -d "{
    \"data\": {
      \"type\": \"workflow-templates\",
      \"attributes\": {
        \"name\": \"Elastic Stack Deployment\",
        \"description\": \"Deploys Elastic Stack on Arch Linux\",
        \"workflow\": ${WORKFLOW_JSON}
      }
    }
  }" \
  "http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-templates"
```

#### 4. List Workflow Templates

```bash
curl -H "Authorization: Bearer $TFE_TOKEN" \
  "http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-templates"
```

#### 5. Execute Workflow

```bash
# Start workflow execution
curl -X POST \
  -H "Authorization: Bearer $TFE_TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "workflow-runs",
      "attributes": {
        "auto_apply": false
      }
    }
  }' \
  "http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-templates/${WORKFLOW_ID}/runs"
```

#### 6. Monitor Workflow Execution

```bash
# Get workflow run status
curl -H "Authorization: Bearer $TFE_TOKEN" \
  "http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-runs/${RUN_ID}"

# Get workflow run logs
curl -H "Authorization: Bearer $TFE_TOKEN" \
  "http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-runs/${RUN_ID}/logs"
```

## Workflow Template Format

Workflow templates use YAML format with the following structure:

```yaml
---
name: "Workflow Name"
description: "Workflow description"
version: "1.0.0"

steps:
  - name: "Step Name"
    type: "ansible" | "terraform" | "validation" | "script"
    timeout: 3600
    enabled: true
    config:
      # Step-specific configuration
    on_success:
      - step: "Next Step Name"
    on_failure:
      - step: "Error Handler Step"

variables:
  - name: "variable_name"
    type: "string"
    default: "default_value"
    description: "Variable description"

notifications:
  event_name:
    type: "webhook" | "email"
    url: "${WEBHOOK_URL}/endpoint"
```

## Troubleshooting

### Error: "YAML syntax error"
- Validate YAML syntax using `yamllint` or Python's `yaml` module
- Check indentation (use spaces, not tabs)
- Verify all strings are properly quoted

### Error: "API connection failed"
- Verify StackWeaver is running
- Check `STACKWEAVER_HOST` environment variable
- Ensure `TFE_TOKEN` is set correctly
- Test connectivity: `curl http://${STACKWEAVER_HOST}/api/v2/ping`

### Error: "Cannot access organization"
- Verify organization name is correct
- Check that your token has permissions for the organization
- List organizations: `curl -H "Authorization: Bearer $TFE_TOKEN" http://${STACKWEAVER_HOST}/api/v2/organizations`

### Workflow execution fails
- Check workflow run logs for detailed error messages
- Verify all referenced playbooks exist
- Ensure inventory files are accessible
- Check that required variables are set

## Integration with Ansible Playbooks

The workflow templates reference Ansible playbooks using relative paths from the repository root:

```yaml
config:
  playbook: "ansible-examples/playbooks/elasticsearch.yml"
  inventory: "ansible-examples/inventory/test.ini"
```

Ensure these paths are correct and the files exist in your repository.

## Next Steps

1. **Create additional workflows** for different deployment scenarios
2. **Test conditional execution** using `on_success` and `on_failure` handlers
3. **Set up notifications** for workflow completion
4. **Integrate with CI/CD** pipelines to trigger workflows automatically

## API Documentation

For more details on the StackWeaver API, refer to:
- TFE API Documentation: https://developer.hashicorp.com/terraform/enterprise/api-docs
- StackWeaver-specific endpoints may differ - check StackWeaver documentation
