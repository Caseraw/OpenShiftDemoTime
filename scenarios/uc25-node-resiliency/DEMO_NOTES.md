```shell
oc get pods -n hybrid-workload -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP,NODE:.spec.nodeName' --no-headers -w
```

```shell
oc adm cordon <INSERT NODE NAME>
```

```shell
oc adm drain <INSERT NODE NAME> --delete-emptydir-data --ignore-daemonsets=true --force
```
