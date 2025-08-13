# Deploy and configure an application for autoscaling.
## A running pod using deployment objects with resource limits.
## Manually scale pods in and out, including scale to zero.
## HPA configured with CPU and memory utilization.
## Generate some CPU and memory load to trigger autoscaling.
## Check pod scaling in and out according to utilization metrics.
## Check the ReplicaSet with every scaling trigger. 



oc new-app php:8.2-ubi8~https://github.com/Caseraw/OpenShiftDemoTime --context-dir=scenarios/uc16-workload-scalability/keda \
  --build-env INSTALL_PKGS="php-pecl-redis" --name myapp



oc new-build --name=php-redis-builder --strategy=docker --binary
oc start-build php-redis-builder --from-dir=.

  oc new-app php:8.2-ubi8~https://github.com/Caseraw/OpenShiftDemoTime --context-dir=scenarios/uc16-workload-scalability/keda \
  --build-env INSTALL_PKGS="php-pecl-redis" --name myapp