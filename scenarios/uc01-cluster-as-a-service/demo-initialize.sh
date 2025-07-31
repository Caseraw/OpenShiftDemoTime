#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
COMPONENTS_BASE="$PROJECT_DIR/assets/components"
SCENARIO_BASE="$PROJECT_DIR/scenarios/uc01-cluster-as-a-service"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# 0) Deploy the first ArgoCD Applications to initiate with
show_msg "show-date" "INFO" "Bootstrap - Deploy the first ArgoCD Applications to initiate" "⏳"

KUSTOMIZE_BASE="argocd-applications/bootstrap"
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$SCENARIO_BASE/argocd-applications/bootstrap" | oc apply -f -

show_msg "show-date" "INFO" "Bootstrap - Deploy the first ArgoCD Applications to initiate" "Completed" "✅"
