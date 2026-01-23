# Scenario

https://github.com/Caseraw/OpenShiftDemoTime/tree/main/scenarios/demo-rhacm-2-virt-spokes

# Create Cluster set

Manually create:
- Create Cluster set "test-poc"
- Add "local cluster" to the cluster set as a resource assignment

# Create Policies for the HUB

## Prep

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: rhacm-hub-policy
  labels:
    kubernetes.io/metadata.name: rhacm-hub-policy
  annotations:
    openshift.io/description: rhacm-hub-policy
    openshift.io/display-name: rhacm-hub-policy
---
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSetBinding
metadata:
  name: test-poc
  namespace: rhacm-hub-policy
spec:
  clusterSet: test-poc
```

## Install GitOps Operator Policy

```yaml
apiVersion: policy.open-cluster-management.io/v1
kind: Policy
metadata:
  name: install-gitops-operator
  namespace: rhacm-hub-policy
  annotations:
    policy.open-cluster-management.io/categories: Baseline hub
    policy.open-cluster-management.io/controls: Baseline hub configuration
    policy.open-cluster-management.io/description: install-gitops-operator
    policy.open-cluster-management.io/standards: Configuration
spec:
  disabled: false
  policy-templates:
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1beta1
        kind: OperatorPolicy
        metadata:
          name: install-gitops-operator
        spec:
          complianceType: musthave
          remediationAction: enforce
          severity: critical
          subscription:
            name: openshift-gitops-operator
            namespace: openshift-gitops-operator
            channel: latest
            source: redhat-operators
            sourceNamespace: openshift-marketplace
          upgradeApproval: Automatic
          versions:
---
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: install-gitops-operator-placement
  namespace: rhacm-hub-policy
spec:
  tolerations:
    - key: cluster.open-cluster-management.io/unreachable
      operator: Exists
    - key: cluster.open-cluster-management.io/unavailable
      operator: Exists
  clusterSets:
    - test-poc
  predicates:
    - requiredClusterSelector:
        labelSelector:
          matchExpressions:
            - key: name
              operator: In
              values:
                - local-cluster
---
apiVersion: policy.open-cluster-management.io/v1
kind: PlacementBinding
metadata:
  name: install-gitops-operator-placement
  namespace: rhacm-hub-policy
placementRef:
  name: install-gitops-operator-placement
  kind: Placement
  apiGroup: cluster.open-cluster-management.io
subjects:
  - name: install-gitops-operator
    kind: Policy
    apiGroup: policy.open-cluster-management.io
```

## Setup GitOps Cluster on HUB

```yaml
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSetBinding
metadata:
  name: test-poc
  namespace: openshift-gitops
spec:
  clusterSet: test-poc
---
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: setup-gitops-cluster-placement
  namespace: openshift-gitops
spec:
  clusterSets:
    - test-poc
---
apiVersion: apps.open-cluster-management.io/v1beta1
kind: GitOpsCluster
metadata:
  name: rhacm-gitops-cluster
  namespace: openshift-gitops
spec:
  argoServer:
    argoNamespace: openshift-gitops
  placementRef:
    name: setup-gitops-cluster-placement
    kind: Placement
    apiVersion: cluster.open-cluster-management.io/v1beta1
```

# Create Policies for the SPOKES

## Prep

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: rhacm-spoke-policy
  labels:
    kubernetes.io/metadata.name: rhacm-spoke-policy
  annotations:
    openshift.io/description: rhacm-spoke-policy
    openshift.io/display-name: rhacm-spoke-policy
---
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSetBinding
metadata:
  name: test-poc
  namespace: rhacm-spoke-policy
spec:
  clusterSet: test-poc
```

# Create the sample application

```yaml
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: podinfo-placement
  namespace: openshift-gitops
spec:
  clusterSets:
    - test-poc
  predicates:
    - requiredClusterSelector:
        labelSelector:
          matchExpressions:
            - key: virtualization
              operator: In
              values:
                - "true"
  numberOfClusters: 1
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: podinfo
  namespace: openshift-gitops
spec:
  generators:
    - clusterDecisionResource:
        configMapRef: acm-placement
        labelSelector:
          matchLabels:
            cluster.open-cluster-management.io/placement: podinfo-placement
        requeueAfterSeconds: 30
  template:
    metadata:
      name: podinfo-{{name}}
      labels:
        velero.io/exclude-from-backup: "true"
    spec:
      project: default
      sources:
        - repositoryType: git
          repoURL: https://github.com/Caseraw/OpenShiftDemoTime.git
          targetRevision: main
          path: scenarios/uc18-metrics-and-logs/podinfo/kustomize
      destination:
        namespace: podinfo
        server: "{{server}}"
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
```

# ODF Redgional DR



https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14
https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/business_continuity/index
https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/networking/index#deploying-submariner-console

https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.19/html-single/deploying_openshift_data_foundation_using_bare_metal_infrastructure/index
https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.19/html-single/configuring_openshift_data_foundation_disaster_recovery_for_openshift_workloads/index#rdr-solution

## label nodes for submariner

```shell
for node in $(oc get nodes -l node-role.kubernetes.io/worker -o name); do
  oc label "$node" submariner.io/gateway=
done
```

## Ensure spoke cluster certs are in trusted CA bundle

```shel

# Hub
# oc get cm default-ingress-cert -n openshift-config-managed -o jsonpath="{['data']['ca-bundle\.crt']}" > cm-clusters.crt

# Spoke 1
oc get cm default-ingress-cert -n openshift-config-managed -o jsonpath="{['data']['ca-bundle\.crt']}" > cm-clusters.crt

# Spoke 2
oc get cm default-ingress-cert -n openshift-config-managed -o jsonpath="{['data']['ca-bundle\.crt']}" >> cm-clusters.crt


# Hub, Spoke 1 and Spoke 2
oc create configmap user-ca-bundle \
  --from-file=ca-bundle.crt=cm-clusters.crt \
  -n openshift-config \
  --dry-run=client -o yaml | oc apply -f -

oc patch proxy cluster --type=merge  --patch='{"spec":{"trustedCA":{"name":"user-ca-bundle"}}}'
```

> https://access.redhat.com/solutions/7113464

## Create ClusterSet

- Create ClusterSet "test-poc"
- Add Spoke clusters for Regiona DR
- Install Submariner addons
- Enable Globalnet
- Wait for all to complete

## ODF with Globalnet

- Update the `StorageCLuster` to add this, per spoke.

```yaml
  network:
    multiClusterService:
      clusterID: aws-cluster-01
      enabled: true
```

```yaml
  network:
    multiClusterService:
      clusterID: aws-cluster-02
      enabled: true
```

Wait for the StorageCluster update to recycle some pods.

Install CEPH tools on both spoke clusters for troubleshooting.

```shell
oc patch storagecluster ocs-storagecluster -n openshift-storage --type json --patch '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
```

## Install the ODF Multicluster Orchestrator on the Hub cluster

## (Globalnet) Connect storage clusters with the ocs-provider-server ServiceExport

Add this on bith Spoke clusters.

```yaml
apiVersion: multicluster.x-k8s.io/v1alpha1
kind: ServiceExport
metadata:
  name: ocs-provider-server
  namespace: openshift-storage
```

Cluster 1

```shell
oc annotate storagecluster ocs-storagecluster -n openshift-storage ocs.openshift.io/api-server-exported-address=aws-cluster-01.ocs-provider-server.openshift-storage.svc.clusterset.local:50051
```

Cluster 2

```shell
oc annotate storagecluster ocs-storagecluster -n openshift-storage ocs.openshift.io/api-server-exported-address=aws-cluster-02.ocs-provider-server.openshift-storage.svc.clusterset.local:50051
```

## Create the DRPolicy on the HUB

- Create DR Policy for a test failover

This will install Operators on the Spoke clusters, it willl take a while for everything to sync up. ~10 minutes.

## Create a sample application

Ensure there is a binding:

```yaml
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSetBinding
metadata:
  name: test-poc
  namespace: openshift-gitops
spec:
  clusterSet: test-poc
```

Ensure the GitOps cluster placement has the "test-poc" in the clusterset:


```yaml
spec:
  clusterSets:
    - test-poc
```

Ensure the GitOps cluster placement has the following tolerations:

```yaml
  tolerations:
  - key: cluster.open-cluster-management.io/unreachable
    operator: Exists
  - key: cluster.open-cluster-management.io/unavailable
    operator: Exists
```

Ensure the GitOps Operator is installed on all spoke clusters.

Ensure the correct RBAC is create on all the clusters:

```yaml
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: argocd-cluster-admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: 'true'
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-applicationset-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
```

Ensure CG for DR using RBD



Create the Application

Sample according to hte docs:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: apptest01
  namespace: openshift-gitops
spec:
  generators:
    - clusterDecisionResource:
        configMapRef: acm-placement
        labelSelector:
          matchLabels:
            cluster.open-cluster-management.io/placement: apptest01-placement
        requeueAfterSeconds: 180
  template:
    metadata:
      name: apptest01-{{name}}
      annotations:
        apps.open-cluster-management.io/ocm-managed-cluster: "{{name}}"
        apps.open-cluster-management.io/ocm-managed-cluster-app-namespace: openshift-gitops
        argocd.argoproj.io/skip-reconcile: "true"
      labels:
        apps.open-cluster-management.io/pull-to-ocm-managed-cluster: "true"
        velero.io/exclude-from-backup: "true"
    spec:
      destination:
        namespace: busybox-sample
        server: "{{server}}"
      project: default
      sources:
        - path: workloads/deployment/odr-regional-rbd
          repoURL: https://github.com/red-hat-storage/ocm-ramen-samples
          targetRevision: main
          repositoryType: git
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
---
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: apptest01-placement
  namespace: openshift-gitops
spec:
  clusterSets:
    - test-poc
  decisionStrategy:
    groupStrategy:
      clustersPerDecisionGroup: 0
  prioritizerPolicy:
    mode: Additive
  spreadPolicy: {}
  predicates:
    - requiredClusterSelector:
        labelSelector:
          matchExpressions:
            - key: name
              operator: In
              values:
                - aws-cluster-01
        claimSelector: {}
  numberOfClusters: 1
```

VM Example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: vmtest01-managed-app
  namespace: openshift-gitops
spec:
  generators:
    - clusterDecisionResource:
        configMapRef: acm-placement
        labelSelector:
          matchLabels:
            cluster.open-cluster-management.io/placement: vmtest01-managed-app-placement
        requeueAfterSeconds: 180
  template:
    metadata:
      name: vmtest01-managed-app-{{name}}
      annotations:
        apps.open-cluster-management.io/ocm-managed-cluster: "{{name}}"
        apps.open-cluster-management.io/ocm-managed-cluster-app-namespace: openshift-gitops
        argocd.argoproj.io/skip-reconcile: "true"
      labels:
        velero.io/exclude-from-backup: "true"
        apps.open-cluster-management.io/pull-to-ocm-managed-cluster: "true"
    spec:
      project: default
      sources:
        - repositoryType: git
          repoURL: https://github.com/Caseraw/OpenShiftDemoTime.git
          targetRevision: main
          path: scenarios/demo-rhacm-2-virt-spokes/kustomize/dummy-virtual-machines
      destination:
        namespace: vmtest01
        server: "{{server}}"
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
---
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: vmtest01-managed-app-placement
  namespace: openshift-gitops
spec:
  numberOfClusters: 1
  predicates:
    - requiredClusterSelector:
        labelSelector:
          matchExpressions:
            - key: name
              operator: In
              values:
                - aws-cluster-01
  clusterSets:
    - test-poc
```

OLD example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: my-vm-apps
  namespace: openshift-gitops
spec:
  generators:
    - clusterDecisionResource:
        configMapRef: acm-placement
        labelSelector:
          matchLabels:
            cluster.open-cluster-management.io/placement: my-vm-apps-placement
        requeueAfterSeconds: 30
  template:
    metadata:
      name: my-vm-apps-{{name}}
      labels:
        velero.io/exclude-from-backup: "true"
    spec:
      project: default
      sources:
        - repositoryType: git
          repoURL: https://github.com/Caseraw/OpenShiftDemoTime.git
          targetRevision: main
          path: scenarios/demo-rhacm-2-virt-spokes/kustomize/dummy-virtual-machines
      destination:
        namespace: my-vm-apps-ns
        server: "{{server}}"
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
        syncOptions:
          - CreateNamespace=true
          - PruneLast=true
---
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: my-vm-apps-placement
  namespace: openshift-gitops
spec:
  tolerations:
  - key: cluster.open-cluster-management.io/unreachable
    operator: Exists
  - key: cluster.open-cluster-management.io/unavailable
    operator: Exists
  clusterSets:
    - test-poc
  predicates:
    - requiredClusterSelector:
        labelSelector:
          matchExpressions:
            - key: name
              operator: NotIn
              values:
                - local-cluster
            - key: name
              operator: In
              values:
                - aws-cluster-01
```






# Links

https://rhpds.github.io/openshift-virt-roadshow-cnv-multi-user/modules/module-07-tempinst.html#create_win

https://www.youtube.com/watch?v=kpejA7_5nL0
https://www.youtube.com/watch?v=-vKzJr4dYxg
