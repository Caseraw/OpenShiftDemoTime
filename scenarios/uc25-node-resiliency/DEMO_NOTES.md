```shell
oc get pods -n hybrid-workload -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP,NODE:.spec.nodeName' --no-headers -w
```

```shell
oc adm cordon <node1>
```

```shell
oc adm drain <node1> --delete-emptydir-data --ignore-daemonsets=true --force
```
