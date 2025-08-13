#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
COMPONENTS_BASE="$PROJECT_DIR/assets/components"
SCENARIO_BASE="$PROJECT_DIR/scenarios/uc19-network-graphs"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# 0) Deploy the first ArgoCD Applications to initiate with
show_msg "show-date" "INFO" "Bootstrap - Deploy the first ArgoCD Applications to initiate" "⏳"

KUSTOMIZE_BASE="argocd-applications/bootstrap"
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$SCENARIO_BASE/kustomize/base/hub-config" | oc apply -f -
kustomize build "$SCENARIO_BASE/argocd-applications/bootstrap-hub" | oc apply -f -
kustomize build "$SCENARIO_BASE/argocd-applications/bootstrap-spoke" | oc apply -f -

show_msg "show-date" "INFO" "Bootstrap - Deploy the first ArgoCD Applications to initiate" "Completed" "✅"

# 1) Copy the AWS Credentials to use in demo-pipelines
SCRIPT="$COMPONENTS_BASE/openshift-rhacm-credentials-aws/copy-secret-for-demo-pipelines.sh"

show_msg "show-date" "INFO" "Bootstrap - Copy AWS Credentials for demo-pipelines" "⏳"
show_msg "show-date" "INFO" "Script" "$SCRIPT"
source "$SCRIPT"
show_msg "show-date" "INFO" "Bootstrap - Copy AWS Credentials for demo-pipelines" "Completed" "✅"
