#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE_01="$PROJECT_DIR/assets/kustomize/base/openshift-serverless"
KUSTOMIZE_BASE_02="$PROJECT_DIR/assets/kustomize/base/openshift-serverless-knative-serving"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Set some variables
NS="openshift-serverless"

# Show opening message
show_msg "show-date" "INFO" "Install OpenShift Serverless Operator" "⏳"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build part 01..."
kustomize build "$KUSTOMIZE_BASE_01" | oc apply -f -

# Wait for Operator to be ready
show_msg "show-date" "INFO" "Wait for Operator to be ready"
run_cmd --infinite -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/serverless-operator.openshift-serverless --for=jsonpath='{.status.phase}'=Succeeded

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
NS="knative-serving"
show_msg "show-date" "INFO" "Wait for KnativeServing setup to be ready"
run_cmd --infinite -- oc -n $NS wait pod -l app=activator --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS wait pod -l app=activator --for=condition=Ready
run_cmd --infinite -- oc -n $NS wait pod -l app=autoscaler --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS wait pod -l app=autoscaler --for=condition=Ready
run_cmd --infinite -- oc -n $NS wait pod -l app=autoscaler-hpa --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS wait pod -l app=autoscaler-hpa --for=condition=Ready
run_cmd --infinite -- oc -n $NS wait pod -l app=controller --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS wait pod -l app=controller --for=condition=Ready
run_cmd --infinite -- oc -n $NS wait pod -l app=webhook --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS wait pod -l app=webhook --for=condition=Ready
run_cmd --infinite -- oc -n $NS-ingress wait pod -l app=3scale-kourier-gateway --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS-ingress wait pod -l app=3scale-kourier-gateway --for=condition=Ready
run_cmd --infinite -- oc -n $NS-ingress wait pod -l app=net-kourier-controller --for=jsonpath='{.status.phase}'=Running
run_cmd --infinite -- oc -n $NS-ingress wait pod -l app=net-kourier-controller --for=condition=Ready

# Show end message
show_msg "show-date" "INFO" "Install OpenShift Serverless Operator" "Completed" "✅"
