# Migrate a VM from VMware to OpenShift

- Go to "Migration" > Plans for virtualization > Namespace "mtv-user1"
- Create plan.
    - name: move-webapp-vmware
    - project: mtv-user1
    - VMware
    - Select VM's for user1 (database, winweb1, winweb)
    - Target provider: host
    - Target namespace: vmexamples-user1
    - Network mapping: segment-migration-to-ocpvirt --- pod network
    - Storage mapping: default...
    - Create plan.
    - Wait for status.
    - Start migration.
    
