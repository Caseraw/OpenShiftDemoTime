# Storyline

## Metrics

- Use example deployment "podinfo".
- Checkout it's performance in the metrics tab of pod, deployment etc.
- Checkout some cluster dashboards for the worload in the namespace "podinfo".
- Checkout some other dashboards, cluster, node etc.
- Checkout the ACM Grafana dashboards for the fleet overview.

- Checkout the custom metrics of "podinfo" on the frontend.
- Checkout the custom metrics in the metrics query page.
- Perform some query for demo purposes.
    - demo_random_metric{namespace="podinfo"}

## Logs

- Checkout the logs of a pod from the "podinfo" deployment.
- Explore the pod log interface.
- Go to Observe => Logs on the left hand side and explore the default landing page.
- Perform a demo query.
    - Filter on pod logs with a certain uptime.
        - `{ k8s_namespace_name="podinfo" } |= "uptime=2:18:42.6726"`
- Checkout the Node logs.
- Checkout the logs from ACM point of view, pod, node etc.
