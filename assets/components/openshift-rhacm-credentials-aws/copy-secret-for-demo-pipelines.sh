#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-rhacm-credentials-aws"
KUSTOMIZE_ASSETS="$KUSTOMIZE_BASE/assets-temporary"
ASSETS_BYO="$PROJECT_DIR/assets/byo"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Show opening message
show_msg "show-date" "INFO" "Copying AWS Secret" "Copying AWS credentials secret for demo pipelines" "⏳"

SRC_SECRET="aws"
SRC_NS="open-cluster-management"
TARGET_SECRET="aws"
TARGET_NS="demo-pipelines"

# Wait for the target namespace to exists
show_msg "show-date" "INFO" "Waiting for target namespace '$TARGET_NS' to be ready..."
run_cmd --infinite -- oc wait ns $TARGET_NS --for=jsonpath='{.metadata.name}'=demo-pipelines

# Get the secret, extract only data, and apply it directly to the target namespace
oc get secret "$SRC_SECRET" -n "$SRC_NS" -o json | jq -r '
  .data as $d |
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: { name: "'"$TARGET_SECRET"'" },
    type: .type,
    data: $d
  }' | oc apply -n "$TARGET_NS" -f -

show_msg "show-date" "INFO" "Secret '$TARGET_SECRET' copied from '$SRC_NS' to '$TARGET_NS'" "✅"

# Show end message
show_msg "show-date" "INFO" "Copy AWS Secret" "AWS credentials secret successfully copied for demo pipelines" "✅"
