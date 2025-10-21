#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
COMPONENTS_BASE="$PROJECT_DIR/assets/components"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# The expectation here is that we have some prerequisites set up:
# - Running OpenShift Cluster
# - Privileged user with access to the Cluster
# - Proper working environment and tools as stated in the VSCode .devcontainer

#--------------------------------------------------------------

# Install the OpenShift Virtualization Operator
SCRIPT="$COMPONENTS_BASE/openshift-virtualization/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Install OpenShift Virtualization Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Install OpenShift Virtualization Operator" "Completed" "✅"
