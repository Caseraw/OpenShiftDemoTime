# Bucket on Cluster 1

```yaml
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: oadp-bucket
  namespace: openshift-storage
spec:
  generateBucketName: oadp-bucket
  storageClassName: openshift-storage.noobaa.io
```

# Bucket name

```txt
oadp-bucket-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

```txt
[default]
aws_access_key_id=xxxxxxx
aws_secret_access_key=xxxxxxx
```

# After installing OADP on both Cluster 1 and Cluster 2 create this secret

```shell
oc create secret generic cloud-credentials \
  --from-file=cloud=credentials \
  -n openshift-adp
```

# On Cluster 1

```yaml
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-dpa
  namespace: openshift-adp
spec:
  configuration:
    velero:
      defaultPlugins:
        - openshift
        - aws       # Required for S3/ODF connection [1]
        - csi       # Required for PVC snapshots [2]
        - kubevirt  # Required for VM processing [2]
    nodeAgent:      # Replaces Restic in OADP 1.5+ for Data Mover [3]
      enable: true
      uploaderType: kopia # Required for Data Mover [4]
  backupLocations:
    - velero:
        provider: aws
        default: true
        credential:
          key: cloud
          name: cloud-credentials # Created from your credentials file
        objectStorage:
          bucket: oadp-bucket-xxxxxxxxxxxxxxxxxxxxxxxxxxxx     # Must match your OBC name
          prefix: oadp
        config:
          region: noobaa
          # On Cluster 1 (Source), you can use internal: https://s3.openshift-storage.svc
          # On Cluster 2 (Target), use the EXTERNAL Route URL: https://s3-openshift-storage.apps.cluster1.example.com
          s3Url: https://s3.openshift-storage.svc
          s3ForcePathStyle: "true"
          insecureSkipTLSVerify: "true" # Required for default ODF self-signed certs [5]
```

# On Cluster 2

```yaml
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-dpa
  namespace: openshift-adp
spec:
  configuration:
    velero:
      defaultPlugins:
        - openshift
        - aws       # Required for S3/ODF connection [1]
        - csi       # Required for PVC snapshots [2]
        - kubevirt  # Required for VM processing [2]
    nodeAgent:      # Replaces Restic in OADP 1.5+ for Data Mover [3]
      enable: true
      uploaderType: kopia # Required for Data Mover [4]
  backupLocations:
    - velero:
        provider: aws
        default: true
        credential:
          key: cloud
          name: cloud-credentials # Created from your credentials file
        objectStorage:
          bucket: oadp-bucket-xxxxxxxxxxxxxxxxxxxxxxxxxxxx     # Must match your OBC name
          prefix: oadp
        config:
          region: noobaa
          # On Cluster 1 (Source), you can use internal: https://s3.openshift-storage.svc
          # On Cluster 2 (Target), use the EXTERNAL Route URL: https://s3-openshift-storage.apps.cluster1.example.com
          s3Url: https://s3-openshift-storage.apps.aws-cluster-01.sandbox5212.opentlc.com
          s3ForcePathStyle: "true"
          insecureSkipTLSVerify: "true" # Required for default ODF self-signed certs [5]
```

# Create a test VM on Cluster 1

Example:
- https://github.com/Caseraw/OpenShiftDemoTime/blob/main/scenarios/demo-rhacm-2-virt-spokes/kustomize/dummy-virtual-machines/resources/rhel-9-test-01-instance.yaml

# Label the VM on Cluster 1

Make sure the VM is labeled! This is how it gets matched in the backup.

# Backup manifest on Cluster 1

```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: backup-rhel-9-test-02
  namespace: openshift-adp
spec:
  # OADP Data Mover: Moves snapshot data to the S3 bucket (Required for cross-cluster)
  snapshotMoveData: true 
  
  # Target the VM's namespace
  includedNamespaces:
    - vm-test-02
  
  # Select ONLY the specific VM we labeled above
  labelSelector:
    matchLabels:
      appname: rhel-9-test-02
  
  # Use the default storage location configured in your DPA
  # storageLocation: default
  
  # How long to keep the backup (e.g., 30 days)
  ttl: 720h0m0s
```

# Restore manifest on Cluster 2

```yaml
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-rhel-9-test-02
  namespace: openshift-adp
spec:
  # Must match the name of the backup created on Cluster 1
  backupName: backup-rhel-9-test-02
  
  # Required to trigger the Data Mover (DataDownload) for the volumes
  restorePVs: true
  
  # Optional: Maps the source namespace to a new name on Cluster 2
  # If omitted, it restores to the same namespace name ('vm-test-01')
  # namespaceMapping:
  #   vm-test-01: vm-test-restored
```

# Delete the backup

```yaml
apiVersion: velero.io/v1
kind: DeleteBackupRequest
metadata:
  name: delete-rhel-9-test-02
  namespace: openshift-adp
spec:
  # The exact name of the Backup CR you want to delete
  backupName: backup-rhel-9-test-02
```