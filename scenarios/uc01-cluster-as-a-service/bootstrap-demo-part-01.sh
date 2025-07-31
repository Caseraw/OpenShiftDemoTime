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

# 0) Setup the prerequisites
SCRIPT="$PROJECT_DIR/assets/byo/credentials-aws/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Perform the scenario prerequisites" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Perform the scenario prerequisites" "Completed" "✅"

# 1) Login to the OpenShift Cluster
SCRIPT="$COMPONENTS_BASE/functions/login-on-openshift.sh"

show_msg "show-date" "INFO" "Bootstrap - Login to OpenShift" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Login to OpenShift" "Completed" "✅"

# 2) Setup the Red Hat Advanced Cluster Management for Kubernetes Operator
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-operator/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the RHACM Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the RHACM Operator" "Completed" "✅"

# 3) Setup the MultiClusterHub
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-multiclusterhub/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the MultiClusterHub in RHACM" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the MultiClusterHub in RHACM" "Completed" "✅"

# 4) Setup the MultiClusterObservability
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-multicluster-observability/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the MultiClusterObservability in RHACM" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the MultiClusterObservability in RHACM" "Completed" "✅"

# 5) Setup the OpenShift GitOps Operator
SCRIPT="$COMPONENTS_BASE/openshift-gitops/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift GitOps Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift GitOps Operator" "Completed" "✅"

# 6) Setup the GitOps Cluster for RHACM
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-gitops-cluster/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the GitOps Cluster for RHACM" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the GitOps Cluster for RHACM" "Completed" "✅"

# 7) Setup the OpenShift Pipelines Operator
SCRIPT="$COMPONENTS_BASE/openshift-pipelines/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift Pipelines Operator" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Setup the OpenShift Pipelines Operator" "Completed" "✅"

# 8) Deploy AWS Credentials to RHACM
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-credentials-aws/setup.sh"

show_msg "show-date" "INFO" "Bootstrap - Deploy AWS Credentials in RHACM" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Deploy AWS Credentials in RHACM" "Completed" "✅"

# 9) Copy the AWS Credentials to use in demo-pipelines
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-credentials-aws/copy-secret-for-demo-pipelines.sh"

show_msg "show-date" "INFO" "Bootstrap - Copy AWS Credentials for demo-pipelines" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Copy AWS Credentials for demo-pipelines" "Completed" "✅"
