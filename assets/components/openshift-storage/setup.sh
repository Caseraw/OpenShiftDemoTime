#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE_01="$PROJECT_DIR/assets/kustomize/base/openshift-storage"
KUSTOMIZE_BASE_02="$PROJECT_DIR/assets/kustomize/base/openshift-storage-config"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Set some variables
NS="openshift-storage"

# Show opening message
show_msg "show-date" "INFO" "Install OpenShift Data Foundation Operator" "⏳"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build part 01..."
kustomize build "$KUSTOMIZE_BASE_01" | oc apply -f -

# Wait for Operator to be ready
show_msg "show-date" "INFO" "Wait for Operator to be ready"
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/odf-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/ocs-client-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build part 02..."
kustomize build "$KUSTOMIZE_BASE_02" | oc apply -f -

# Wait for Operator configuration tro be ready
show_msg "show-date" "INFO" "Wait for Operators and configuration to be ready"
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/cephcsi-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/mcg-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/ocs-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/odf-csi-addons-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/odf-dependencies.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/odf-prometheus-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/recipe.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait ClusterServiceVersion -l operators.coreos.com/rook-ceph-operator.openshift-storage --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait StorageCluster ocs-storagecluster --for=jsonpath='{.status.phase}'=Ready

# Wait for Workload to be ready
show_msg "show-date" "INFO" "Wait for Workload etc. to be ready"
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait sc local-storage-odf --for=jsonpath='{.provisioner}'=kubernetes.io/no-provisioner
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait sc ocs-storagecluster-ceph-rbd --for=jsonpath='{.provisioner}'=openshift-storage.rbd.csi.ceph.com
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait sc ocs-storagecluster-cephfs --for=jsonpath='{.provisioner}'=openshift-storage.cephfs.csi.ceph.com
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait sc openshift-storage.noobaa.io --for=jsonpath='{.provisioner}'=openshift-storage.noobaa.io/obc
run_cmd --infinite --infinite-timeout 3600 -- oc -n $NS wait pods -l app=rook-ceph-osd --for=jsonpath='{.status.phase}'=Running

# Setup plugins
show_msg "show-date" "INFO" "Setting up the console plugins"
NEW_PLUGINS=("odf-console" "odf-client-console")
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
show_msg "show-date" "INFO" "Install OpenShift Data Foundation Operator" "Completed" "✅"
