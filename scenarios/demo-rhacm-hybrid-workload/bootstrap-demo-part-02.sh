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
# - Required credentials for the AWS account that we will be using

# 0) Login to the OpenShift Cluster
SCRIPT="$COMPONENTS_BASE/functions/login-on-openshift.sh"

show_msg "show-date" "INFO" "Bootstrap - Login to OpenShift" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Login to OpenShift" "Completed" "✅"

# 1) Deploy the Red Hat Virtualization Cluster on AWS
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-deploy-aws-cluster/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Deploy the Red Hat Virtualization Cluster on AWS" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Deploy the Red Hat Virtualization Cluster on AWS" "Completed" "✅"
