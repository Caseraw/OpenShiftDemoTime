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

# Setup the Red Hat Advanced Cluster Management for Kubernetes Operator
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-operator/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the RHACM Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the RHACM Operator" "Completed" "✅"

# Setup the MultiClusterHub
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-multiclusterhub/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the MultiClusterHub in RHACM" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the MultiClusterHub in RHACM" "Completed" "✅"

# Setup the OpenShift GitOps Operator
SCRIPT="$COMPONENTS_BASE/openshift-gitops/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift GitOps Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift GitOps Operator" "Completed" "✅"

# Setup the GitOps Cluster for RHACM
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-gitops-cluster/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the GitOps Cluster for RHACM" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the GitOps Cluster for RHACM" "Completed" "✅"

# Setup the OpenShift Pipelines Operator
SCRIPT="$COMPONENTS_BASE/openshift-pipelines/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift Pipelines Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift Pipelines Operator" "Completed" "✅"
