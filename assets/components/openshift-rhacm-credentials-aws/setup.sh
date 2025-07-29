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
show_msg "show-date" "INFO" "Deploy AWS Credentials" "Advanced Cluster Management for Kubernetes" "⏳"

# Create a temporary assets directory
mkdir -p $KUSTOMIZE_ASSETS

# Copy required external files into the temp directory
cp "$ASSETS_BYO/pull-secret/pull-secret.txt" "$KUSTOMIZE_ASSETS/pull-secret.txt"
cp "$ASSETS_BYO/ssh-keys/id_rsa" "$KUSTOMIZE_ASSETS/id_rsa"
cp "$ASSETS_BYO/ssh-keys/id_rsa.pub" "$KUSTOMIZE_ASSETS/id_rsa.pub"
cp "$ASSETS_BYO/credentials-aws/bundle.env" "$KUSTOMIZE_ASSETS/bundle.env"

# Run Kustomize build and apply
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

# Cleanup: Remove the temporary directory
rm -rf "$KUSTOMIZE_ASSETS"

# Show end message
show_msg "show-date" "INFO" "Deploy AWS Credentials" "Completed" "✅"
