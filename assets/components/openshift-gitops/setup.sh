#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-gitops"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Set some variables
NS="openshift-gitops"

# Show opening message
show_msg "show-date" "INFO" "Install the Red Hat GitOps Operator" "⏳"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

# Wait for OpenShift GitOps ArgoCD Operator and Instance to be ready
show_msg "show-date" "INFO" "Check OpenShift GitOps ArgoCD Operator and Instance to be ready..."

run_cmd --infinite -- oc -n $NS-operator wait ClusterServiceVersion -l olm.managed=true --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite -- oc -n $NS wait ClusterServiceVersion -l olm.copiedFrom=openshift-gitops-operator --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.applicationController}'=Running
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.phase}'=Available
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.applicationSetController}'=Running
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.redis}'=Running
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.repo}'=Running
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.server}'=Running
run_cmd --infinite -- oc -n $NS wait ArgoCD openshift-gitops --for=jsonpath='{.status.sso}'=Running

# Wait for Workload to be ready
show_msg "show-date" "INFO" "Check for OpenShift GitOps ArgoCD workload to be ready..."
pods=$(oc -n $NS get pod --no-headers -o custom-columns=NAME:.metadata.name)
for pod in ${pods}; do
  oc -n $NS wait pod $pod --for=jsonpath='{.status.phase}'=Running
  oc -n $NS wait pod $pod --for=condition=Ready
done

# Setup plugins
show_msg "show-date" "INFO" "Setting up the console plugins"
NEW_PLUGINS=("gitops-plugin")
readarray -t CURRENT_PLUGINS < <(oc get console.operator cluster -o json | jq -r '.spec.plugins[]' | grep -v '^null$' || true)

ALL_PLUGINS=("${CURRENT_PLUGINS[@]}")
for plugin in "${NEW_PLUGINS[@]}"; do
  if [[ ! " ${ALL_PLUGINS[*]} " =~ " ${plugin} " ]]; then
    ALL_PLUGINS+=("$plugin")
  fi
done

JSON_ARRAY=$(printf '%s\n' "${ALL_PLUGINS[@]}" | jq -R . | jq -s .)
oc patch console.operator cluster --type='merge' -p "{\"spec\": {\"plugins\": $JSON_ARRAY}}"

# Show end message
show_msg "show-date" "INFO" "Install the Red Hat GitOps Operator" "Completed" "✅"
