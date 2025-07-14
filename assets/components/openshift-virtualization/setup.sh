#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE_01="$PROJECT_DIR/assets/kustomize/base/openshift-virtualization"
KUSTOMIZE_BASE_02="$PROJECT_DIR/assets/kustomize/base/openshift-virtualization-config"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Set some variables
NS="openshift-cnv"

# Show opening message
show_msg "show-date" "INFO" "Install OpenShift Virtualization Operator" "⏳"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build part 01..."
kustomize build "$KUSTOMIZE_BASE_01" | oc apply -f -

# Wait for Operator to be ready
show_msg "show-date" "INFO" "Wait for Operator to be ready"
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/kubevirt-hyperconverged.openshift-cnv --for=jsonpath='{.status.phase}'=Succeeded

# Wait for Workload to be ready
show_msg "show-date" "INFO" "Wait for Workload to be ready"
pods=$(oc -n $NS get pod --no-headers -o custom-columns=NAME:.metadata.name)
for pod in ${pods}; do
  oc -n $NS wait pod $pod --for=jsonpath='{.status.phase}'=Running
  oc -n $NS wait pod $pod --for=condition=Ready
done

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build part 02..."
kustomize build "$KUSTOMIZE_BASE_02" | oc apply -f -

# Wait for Operator configuration tro be ready
show_msg "show-date" "INFO" "Wait for HyperConverged configuration to be ready"
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait HyperConverged kubevirt-hyperconverged --for=jsonpath='{.status.systemHealthStatus}'=healthy
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait HyperConverged kubevirt-hyperconverged --for=jsonpath='{.status.infrastructureHighlyAvailable}'=true

# Wait for Workload to be ready
show_msg "show-date" "INFO" "Wait for Workload to be ready"
pods=$(oc -n $NS get pod --no-headers -o custom-columns=NAME:.metadata.name)
for pod in ${pods}; do
  oc -n $NS wait pod $pod --for=jsonpath='{.status.phase}'=Running
  oc -n $NS wait pod $pod --for=condition=Ready
done

# Show end message
show_msg "show-date" "INFO" "Install OpenShift Virtualization Operator" "Completed" "✅"
