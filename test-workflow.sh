#!/bin/bash

# Script to test StackWeaver workflow templates
# Usage: ./test-workflow.sh <workflow-file> [organization] [workflow-id]
# Example: ./test-workflow.sh workflows/elasticsearch-deployment.yml my-org

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if required environment variables are set
if [ -z "$TFE_TOKEN" ]; then
    echo -e "${RED}Error: TFE_TOKEN environment variable is not set${NC}"
    echo "Please set it with: export TFE_TOKEN='your-token'"
    exit 1
fi

# Configuration
STACKWEAVER_HOST="${STACKWEAVER_HOST:-localhost:8022}"
ORG_NAME="${ORG_NAME:-}"

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Usage: $0 <workflow-file> [organization] [workflow-id]${NC}"
    echo "Example: $0 workflows/elasticsearch-deployment.yml my-org"
    echo ""
    echo "Environment variables:"
    echo "  TFE_TOKEN - Required: Your TFE/StackWeaver token"
    echo "  STACKWEAVER_HOST - Optional: Defaults to localhost:8022"
    echo "  ORG_NAME - Optional: Organization name"
    exit 1
fi

WORKFLOW_FILE="$1"
ORG_NAME="${2:-${ORG_NAME}}"
WORKFLOW_ID="$3"

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo -e "${RED}Error: Workflow file not found: $WORKFLOW_FILE${NC}"
    exit 1
fi

if [ -z "$ORG_NAME" ]; then
    echo -e "${YELLOW}ORG_NAME not set. Please provide organization name.${NC}"
    echo "Usage: $0 <workflow-file> <organization> [workflow-id]"
    exit 1
fi

# Function to print section header
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to validate YAML syntax (basic check)
validate_yaml() {
    print_header "Validating Workflow YAML"
    
    if command -v yamllint &> /dev/null; then
        echo -e "${YELLOW}Running yamllint...${NC}"
        yamllint "$WORKFLOW_FILE" && echo -e "${GREEN}✓ YAML syntax is valid${NC}" || {
            echo -e "${YELLOW}Note: yamllint found issues, but continuing...${NC}"
        }
    elif command -v python3 &> /dev/null; then
        echo -e "${YELLOW}Checking YAML syntax with Python...${NC}"
        python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW_FILE'))" 2>/dev/null && \
            echo -e "${GREEN}✓ YAML syntax is valid${NC}" || {
            echo -e "${RED}✗ YAML syntax error${NC}"
            return 1
        }
    else
        echo -e "${YELLOW}No YAML validator found, skipping validation${NC}"
    fi
}

# Function to parse workflow metadata
parse_workflow() {
    print_header "Parsing Workflow Template"
    
    WORKFLOW_NAME=$(grep -E "^name:" "$WORKFLOW_FILE" | head -1 | sed 's/name: *"\(.*\)"/\1/' | sed "s/name: *'\(.*\)'/\1/" | sed 's/name: *\(.*\)/\1/' | xargs)
    WORKFLOW_DESC=$(grep -E "^description:" "$WORKFLOW_FILE" | head -1 | sed 's/description: *"\(.*\)"/\1/' | sed "s/description: *'\(.*\)'/\1/" | sed 's/description: *\(.*\)/\1/' | xargs)
    WORKFLOW_VERSION=$(grep -E "^version:" "$WORKFLOW_FILE" | head -1 | sed 's/version: *"\(.*\)"/\1/' | sed "s/version: *'\(.*\)'/\1/" | sed 's/version: *\(.*\)/\1/' | xargs)
    
    echo -e "Name: ${GREEN}${WORKFLOW_NAME}${NC}"
    echo -e "Description: ${GREEN}${WORKFLOW_DESC}${NC}"
    echo -e "Version: ${GREEN}${WORKFLOW_VERSION}${NC}"
    
    STEP_COUNT=$(grep -c "^- name:" "$WORKFLOW_FILE" || echo "0")
    echo -e "Steps: ${GREEN}${STEP_COUNT}${NC}"
}

# Function to check API connectivity
check_api() {
    print_header "Checking StackWeaver API Connectivity"
    
    local PING_URL="http://${STACKWEAVER_HOST}/api/v2/ping"
    local RESPONSE=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TFE_TOKEN" "$PING_URL")
    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo -e "${GREEN}✓ API is reachable${NC}"
        echo "Response: $BODY"
        return 0
    else
        echo -e "${RED}✗ API connection failed${NC}"
        echo "HTTP Code: $HTTP_CODE"
        echo "Response: $BODY"
        return 1
    fi
}

# Function to check organization access
check_organization() {
    print_header "Checking Organization Access"
    
    local ORG_URL="http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}"
    local RESPONSE=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TFE_TOKEN" "$ORG_URL")
    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo -e "${GREEN}✓ Organization access granted${NC}"
        echo "Organization: $ORG_NAME"
        return 0
    else
        echo -e "${RED}✗ Cannot access organization: ${ORG_NAME}${NC}"
        echo "HTTP Code: $HTTP_CODE"
        echo "Response: $BODY"
        return 1
    fi
}

# Function to create workflow template
create_workflow_template() {
    print_header "Creating/Updating Workflow Template"
    
    local API_URL="http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-templates"
    
    # Read workflow file content and convert to JSON
    # Note: This is a simplified approach. In production, you might want to use a proper YAML-to-JSON converter
    local WORKFLOW_CONTENT=$(cat "$WORKFLOW_FILE" | python3 -c "
import sys, json, yaml
try:
    data = yaml.safe_load(sys.stdin)
    print(json.dumps(data))
except Exception as e:
    print(json.dumps({'error': str(e)}), file=sys.stderr)
    sys.exit(1)
" 2>/dev/null)
    
    if [ -z "$WORKFLOW_CONTENT" ] || echo "$WORKFLOW_CONTENT" | grep -q '"error"'; then
        echo -e "${RED}✗ Failed to parse workflow YAML${NC}"
        return 1
    fi
    
    # Prepare JSON:API format payload
    local PAYLOAD=$(cat <<EOF
{
    "data": {
        "type": "workflow-templates",
        "attributes": {
            "name": "${WORKFLOW_NAME}",
            "description": "${WORKFLOW_DESC}",
            "version": "${WORKFLOW_VERSION}",
            "workflow": ${WORKFLOW_CONTENT}
        }
    }
}
EOF
)
    
    echo -e "${YELLOW}Creating workflow template...${NC}"
    local RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Authorization: Bearer $TFE_TOKEN" \
        -H "Content-Type: application/vnd.api+json" \
        -d "$PAYLOAD" \
        "$API_URL")
    
    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
        echo -e "${GREEN}✓ Workflow template created successfully${NC}"
        # Extract workflow ID from response
        WORKFLOW_ID=$(echo "$BODY" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('data', {}).get('id', ''))
except:
    pass
" 2>/dev/null)
        
        if [ -n "$WORKFLOW_ID" ]; then
            echo "Workflow ID: $WORKFLOW_ID"
        fi
        return 0
    else
        echo -e "${YELLOW}Note: Creation returned HTTP ${HTTP_CODE}${NC}"
        echo "Response: $BODY"
        
        # If workflow exists, try to get existing ID
        echo -e "${YELLOW}Attempting to find existing workflow...${NC}"
        list_workflow_templates
        return 0
    fi
}

# Function to list workflow templates
list_workflow_templates() {
    print_header "Listing Workflow Templates"
    
    local API_URL="http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-templates"
    local RESPONSE=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TFE_TOKEN" "$API_URL")
    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "$BODY" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    templates = data.get('data', [])
    if templates:
        print('Available workflows:')
        for t in templates:
            print(f\"  - {t.get('attributes', {}).get('name', 'Unknown')} (ID: {t.get('id', 'N/A')})\")
    else:
        print('No workflows found')
except Exception as e:
    print(f'Error parsing response: {e}')
    print('Raw response:', data if 'data' in locals() else 'N/A')
" 2>/dev/null || echo "$BODY"
    else
        echo -e "${YELLOW}Note: Could not list workflows (HTTP ${HTTP_CODE})${NC}"
        echo "This endpoint might not be implemented yet"
    fi
}

# Function to execute workflow
execute_workflow() {
    print_header "Executing Workflow"
    
    if [ -z "$WORKFLOW_ID" ]; then
        echo -e "${YELLOW}Workflow ID not provided. Skipping execution.${NC}"
        echo "To execute a workflow, provide the workflow ID as the third argument:"
        echo "$0 $WORKFLOW_FILE $ORG_NAME <workflow-id>"
        return 0
    fi
    
    local API_URL="http://${STACKWEAVER_HOST}/api/v2/organizations/${ORG_NAME}/workflow-templates/${WORKFLOW_ID}/runs"
    
    local PAYLOAD=$(cat <<EOF
{
    "data": {
        "type": "workflow-runs",
        "attributes": {
            "auto_apply": false
        }
    }
}
EOF
)
    
    echo -e "${YELLOW}Starting workflow execution...${NC}"
    local RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Authorization: Bearer $TFE_TOKEN" \
        -H "Content-Type: application/vnd.api+json" \
        -d "$PAYLOAD" \
        "$API_URL")
    
    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
        echo -e "${GREEN}✓ Workflow execution started${NC}"
        local RUN_ID=$(echo "$BODY" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('data', {}).get('id', ''))
except:
    pass
" 2>/dev/null)
        
        if [ -n "$RUN_ID" ]; then
            echo "Run ID: $RUN_ID"
            echo ""
            echo "Monitor the run at:"
            echo "  http://${STACKWEAVER_HOST}/app/${ORG_NAME}/workflow-runs/${RUN_ID}"
        fi
        return 0
    else
        echo -e "${YELLOW}Note: Execution endpoint returned HTTP ${HTTP_CODE}${NC}"
        echo "Response: $BODY"
        echo ""
        echo "This endpoint might not be implemented yet, or the API format may differ."
        return 0
    fi
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║  StackWeaver Workflow Template Tester  ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    validate_yaml || exit 1
    parse_workflow
    check_api || exit 1
    check_organization || exit 1
    create_workflow_template
    list_workflow_templates
    execute_workflow
    
    print_header "Test Complete"
    echo -e "${GREEN}✓ Workflow template testing completed${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review the workflow template in StackWeaver UI"
    echo "2. Execute the workflow manually if auto-execution didn't work"
    echo "3. Monitor workflow execution and check logs"
}

# Run main function
main
