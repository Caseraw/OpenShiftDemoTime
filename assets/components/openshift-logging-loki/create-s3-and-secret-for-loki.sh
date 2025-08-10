#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
ASSETS_BYO="$PROJECT_DIR/assets/byo"

# Load additional functions
source "$PROJECT_DIR/assets/scripts/shell/lib/show_msg.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/show_divider.sh"
source "$PROJECT_DIR/assets/scripts/shell/lib/run_cmd.sh"

# Load AWS credentials & base domain
source "$ASSETS_BYO/credentials-aws/aws-cli.env"
source "$ASSETS_BYO/credentials-aws/basedomain.env"

# Set some variables
LOKI_S3_BUCKET=loki-$GUID_DOMAIN
OCP_CLUSTER_NAME=$(oc get infrastructure cluster -o jsonpath='{.status.infrastructureName}')

# Show opening message
show_msg "show-date" "INFO" "Create S3 bucket for Loki" "⏳"

# Create S3 bucket for Loki
show_msg "show-date" "INFO" "Create AWS S3 bucket" "s3://$LOKI_S3_BUCKET-$OCP_CLUSTER_NAME"
if aws s3 ls "s3://$LOKI_S3_BUCKET-$OCP_CLUSTER_NAME" 2>/dev/null; then
    show_msg "show-date" "INFO" "S3 bucket already exists" "s3://$LOKI_S3_BUCKET-$OCP_CLUSTER_NAME"
else
    aws s3 mb s3://$LOKI_S3_BUCKET-$OCP_CLUSTER_NAME
fi

# Ensure openshift-logging namespace exists
if ! oc get namespace openshift-logging >/dev/null 2>&1; then
    show_msg "show-date" "INFO" "Creating namespace" "openshift-logging"
    oc apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-logging 
  labels:
    openshift.io/cluster-monitoring: "true" 
EOF
else
    show_msg "show-date" "INFO" "Namespace already exists" "openshift-logging"
fi

# Create secret for S3 bucket
show_msg "show-date" "INFO" "Creating Loki S3 secret" "logging-loki-s3"

oc apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: logging-loki-s3
  namespace: openshift-logging
stringData: 
  access_key_id: $AWS_ACCESS_KEY_ID
  access_key_secret: $AWS_SECRET_ACCESS_KEY
  bucketnames: $LOKI_S3_BUCKET-$OCP_CLUSTER_NAME
  endpoint: https://s3.$AWS_DEFAULT_REGION.amazonaws.com
  region: $AWS_DEFAULT_REGION
EOF

# Show end message
show_msg "show-date" "INFO" "Create S3 bucket and secret for Loki" "Completed" "✅"
