#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-rhacm-multiclusterhub"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Set some variables
NS="open-cluster-management"

# Show opening message
show_msg "show-date" "INFO" "Deploy the MultiClusterHub in RHACM" "⏳"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

# Wait for Operator to be ready
show_msg "show-date" "INFO" "Wait for Operator to be ready"
run_cmd --infinite -- oc -n $NS wait ClusterServiceVersion -l olm.managed=true --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite -- oc -n $NS wait MultiClusterHub multiclusterhub --for=jsonpath='{.status.phase}'=Running

# Wait for Workload to be ready
show_msg "show-date" "INFO" "Wait for Workload to be ready"

pods=$(oc -n $NS get pod --no-headers -o custom-columns=NAME:.metadata.name)
for pod in ${pods}; do
  run_cmd --infinite -- oc -n $NS wait pod $pod --for=jsonpath='{.status.phase}'=Running
  run_cmd --infinite -- oc -n $NS wait pod $pod --for=condition=Ready
done

# Show end message
show_msg "show-date" "INFO" "Deploy the MultiClusterHub in RHACM" "Completed" "✅"
