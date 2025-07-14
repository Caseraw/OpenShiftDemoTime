#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-pipelines"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Set some variables
NS="openshift-operators"

# Show opening message
show_msg "show-date" "INFO" "Install the OpenShift Pipelines Operator" "⏳"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

# Wait for Operator to be ready
show_msg "show-date" "INFO" "Wait for Operator to be ready"
run_cmd --infinite -- oc -n $NS wait ClusterServiceVersion -l olm.managed=true --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite -- oc get tektonconfigs config --no-headers

# Wait for Workload to be ready
show_msg "show-date" "INFO" "Wait for Workload to be ready"
oc -n $NS wait pod -l app=openshift-pipelines-operator --for=jsonpath='{.status.phase}'=Running --timeout=900s
oc -n $NS wait pod -l app=openshift-pipelines-operator --for=condition=Ready --timeout=900s

# Show end message
show_msg "show-date" "INFO" "Install the OpenShift Pipelines Operator" "Completed" "✅"
