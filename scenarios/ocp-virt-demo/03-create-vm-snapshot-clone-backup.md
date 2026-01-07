# Create VM Snapshot, clone and backup

**Snapshot**
- Go to VM vm "fedora01" in namespace "vmexamples-user1".
- Select VM "fedora01".
- Create snapshot.
- Intentionally break the VM "fedora01" with `sudo rm -rf /boot/grub2; sudo shutdown -r now`.
    - .... *VM does not boot*
- Shut down VM > Force Shutdown VM
- Restore snapshot > Start VM.

**Clone**
- Go to VM vm "fedora01" in namespace "vmexamples-user1".
- Select VM "fedora01".
- Create clone, uncheck "Start VM once created"
- Rename "fedora01" into "fedora02".
- Start VM "fedora02".

**Backup**
- OADP Operator, project "oadp-user1"
- Create backup from VM "fedora02".

```yaml
---
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: backup-fedora02
  namespace: oadp-user1
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
  - vmexamples-user1
  snapshotMoveData: false
```

- Delete the VM "fedora02".
- Restore VM "fedora02".

```yaml
---
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-fedora02
  namespace: oadp-user1
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