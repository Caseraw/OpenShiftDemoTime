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

# 1) Install the OpenShift Serverless Operator
SCRIPT="$COMPONENTS_BASE/openshift-serverless/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Install OpenShift Serverless Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Install OpenShift Serverless Operator" "Completed" "✅"

# 2) Setup the OpenShift GitOps Operator
SCRIPT="$COMPONENTS_BASE/openshift-gitops/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift GitOps Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift GitOps Operator" "Completed" "✅"

# 3) Setup the OpenShift Pipelines Operator
SCRIPT="$COMPONENTS_BASE/openshift-pipelines/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift Pipelines Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift Pipelines Operator" "Completed" "✅"
