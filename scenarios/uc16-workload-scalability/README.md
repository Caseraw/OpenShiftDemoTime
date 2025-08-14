# Deploy and configure an application for autoscaling.
## A running pod using deployment objects with resource limits.
## Manually scale pods in and out, including scale to zero.
## HPA configured with CPU and memory utilization.
## Generate some CPU and memory load to trigger autoscaling.
## Check pod scaling in and out according to utilization metrics.
## Check the ReplicaSet with every scaling trigger. 


1 - install Custom Metrics Autoscaler
2 - create keda CRD instace keda/resources/keda.yaml
3 - push the sample app and scaledobject
oc create -k keda/resources