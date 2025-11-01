# Notes

```shell
sudo rm -rf /boot/grub2; sudo shutdown -r now
```

```yaml
---
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: backup-fedora02
  namespace: oadp-user2
  labels:
    velero.io/storage-location: default
spec:
  defaultVolumesToFsBackup: false
  orLabelSelectors:
  - matchLabels:
      app: fedora02
  - matchLabels:
      vm.kubevirt.io/name: fedora02
  csiSnapshotTimeout: 10m0s
  ttl: 720h0m0s
  itemOperationTimeout: 4h0m0s
  storageLocation: oadp-dpa-1
  hooks: {}
  includedNamespaces:
  - vmexamples-user2
  snapshotMoveData: false
```

```yaml
---
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-fedora02
  namespace: oadp-user2
spec:
  backupName: backup-fedora02
  includedResources: []
  excludedResources:
  - nodes
  - events
  - events.events.k8s.io
  - backups.velero.io
  - restores.velero.io
  restorePVs: true
```
