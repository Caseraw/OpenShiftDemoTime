#!/bin/bash
## THIS IS NOT COMPLETE YET, it needs more refinement to act as a temlplate.

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

# Read static files once
mapfile -t SSH_PRIV_KEY_LINES < "$ASSETS_BYO/ssh-keys/id_rsa"
mapfile -t SSH_PUB_KEY_LINES < "$ASSETS_BYO/ssh-keys/id_rsa.pub"
mapfile -t PULL_SECRET_LINES < "$ASSETS_BYO/pull-secret/pull-secret.txt"

# Define variables
CLUSTER="aws-cluster-01"
CLUSTER_LABELS=(
  "environment: dev"
)
CLUSTER_SET="default"

SSH_PRIV_KEY=$(printf "%s\n" "${SSH_PRIV_KEY_LINES[@]}")
SSH_PUB_KEY=$(printf "%s\n" "${SSH_PUB_KEY_LINES[@]}")
PULL_SECRET=$(printf "%s\n" "${PULL_SECRET_LINES[@]}")

# Function to deploy a cluster
deploy_cluster() {
    local AWS_CLUSTER_NAME=$1
    local MANAGED_CLUSTER_LABELS="${CLUSTER_LABELS}"

    show_msg "show-date" "INFO" "Deploying cluster" "$AWS_CLUSTER_NAME"

    INSTALL_CONFIG_YAML=$(cat <<EOF
apiVersion: v1
metadata:
  name: $AWS_CLUSTER_NAME
baseDomain: $baseDomain
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  replicas: 3
  platform:
    aws:
      rootVolume:
        iops: 4000
        size: 300
        type: io1
      type: m5.4xlarge
compute:
- hyperthreading: Enabled
  architecture: amd64
  name: worker
  replicas: 3
  platform:
    aws:
      rootVolume:
        iops: 2000
        size: 300
        type: io1
      type: m5d.metal
networking:
  networkType: OVNKubernetes
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: $AWS_DEFAULT_REGION
pullSecret: "" # skip, hive will inject based on its secrets
sshKey: |-
    $SSH_PUB_KEY
EOF
)

    INSTALL_CONFIG_YAML_B64=$(echo "$INSTALL_CONFIG_YAML" | base64 -w 0)

    # Apply manifest to create the namespace
    # cat <<EOF > $AWS_CLUSTER_NAME.txt
    oc apply -f - <<EOF
kind: Namespace
apiVersion: v1
metadata:
  name: $AWS_CLUSTER_NAME
  labels:
    # cluster.open-cluster-management.io/managedCluster: $AWS_CLUSTER_NAME
    kubernetes.io/metadata.name: $AWS_CLUSTER_NAME
    # open-cluster-management.io/cluster-name: $AWS_CLUSTER_NAME
EOF

    # Apply cluster deployment YAML
    # cat <<EOF >> $AWS_CLUSTER_NAME.txt
    oc apply -f - <<EOF
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: $AWS_CLUSTER_NAME
  namespace: $AWS_CLUSTER_NAME
  labels:
    cloud: AWS
    region: $AWS_DEFAULT_REGION
    vendor: OpenShift
    cluster.open-cluster-management.io/clusterset: $CLUSTER_SET
spec:
  baseDomain: $baseDomain
  clusterName: $AWS_CLUSTER_NAME
  controlPlaneConfig:
    servingCertificates: {}
  installAttemptsLimit: 1
  installed: false
  platform:
    aws:
      credentialsSecretRef:
        name: $AWS_CLUSTER_NAME-aws-creds
      region: $AWS_DEFAULT_REGION
  provisioning:
    installConfigSecretRef:
      name: $AWS_CLUSTER_NAME-install-config
    sshPrivateKeySecretRef:
      name: $AWS_CLUSTER_NAME-ssh-private-key
    imageSetRef:
      #quay.io/openshift-release-dev/ocp-release:4.19.3-multi
      name: img4.19.3-multi-appsub
  pullSecretRef:
    name: $AWS_CLUSTER_NAME-pull-secret
---
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  labels:
    cloud: Amazon
    region: $AWS_DEFAULT_REGION
    name: $AWS_CLUSTER_NAME
    vendor: OpenShift
    cluster.open-cluster-management.io/clusterset: $CLUSTER_SET
$(for label in "${CLUSTER_LABELS[@]}"; do echo "    $label"; done)
  name: $AWS_CLUSTER_NAME
spec:
  hubAcceptsClient: true
---
apiVersion: hive.openshift.io/v1
kind: MachinePool
metadata:
  name: $AWS_CLUSTER_NAME-worker
  namespace: $AWS_CLUSTER_NAME
spec:
  clusterDeploymentRef:
    name: $AWS_CLUSTER_NAME
  name: worker
  platform:
    aws:
      rootVolume:
        iops: 2000
        size: 300
        type: io1
      type: m5d.metal
  replicas: 3
---
apiVersion: v1
kind: Secret
metadata:
  name: $AWS_CLUSTER_NAME-pull-secret
  namespace: $AWS_CLUSTER_NAME
stringData:
  .dockerconfigjson: |-
    $PULL_SECRET
type: kubernetes.io/dockerconfigjson
---
apiVersion: v1
kind: Secret
metadata:
  name: $AWS_CLUSTER_NAME-install-config
  namespace: $AWS_CLUSTER_NAME
type: Opaque
data:
  # Base64 encoding of install-config yaml
  install-config.yaml: $INSTALL_CONFIG_YAML_B64
---
apiVersion: v1
kind: Secret
metadata:
  name: $AWS_CLUSTER_NAME-ssh-private-key
  namespace: $AWS_CLUSTER_NAME
stringData:
  ssh-privatekey: |-
$(echo "$SSH_PRIV_KEY" | sed 's/^/    /')
type: Opaque
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: $AWS_CLUSTER_NAME-aws-creds
  namespace: $AWS_CLUSTER_NAME
stringData:
  aws_access_key_id: $AWS_ACCESS_KEY_ID
  aws_secret_access_key: $AWS_SECRET_ACCESS_KEY
---
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: $AWS_CLUSTER_NAME
  namespace: $AWS_CLUSTER_NAME
spec:
  clusterName: $AWS_CLUSTER_NAME
  clusterNamespace: $AWS_CLUSTER_NAME
  clusterLabels:
    cloud: Amazon
    vendor: OpenShift
  applicationManager:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  certPolicyController:
    enabled: true
EOF
  
    sleep 5
    show_msg "show-date" "INFO" "Deployed successfully!" "Cluster $AWS_CLUSTER_NAME"
}

# Show opening message
show_msg "show-date" "INFO" "Deploy new AWS Cluster" "⏳"

# Deploy cluster
deploy_cluster "$CLUSTER"

# Wait deployed cluster to be ready
show_msg "show-date" "INFO" "Wait new Cluster to be ready..."

run_cmd --infinite --infinite-timeout 3600 -- oc -n aws-cluster-01 wait pod -l hive.openshift.io/job-type=provision --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite --infinite-timeout 3600 -- oc -n aws-cluster-01 wait job -l hive.openshift.io/job-type=provision --for=jsonpath='{.status.succeeded}'=1

# Show end message
show_msg "show-date" "INFO" "Deploy new AWS Cluster" "Completed" "✅"
