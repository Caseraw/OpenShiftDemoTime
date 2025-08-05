# Demo - Use Case 01 - Cluster as a Service

This scenario is all about showing the capability of Cluster as a Service. The
idea behind this is to use the Hub-Spoke model using RHACM (Red Hat Advanced
Cluster Management) as the base ground (the Hub) from which to start deploying
other OpenShift Clusters (managed by RHACM) on AWS.

## Prerequisites

Make sure to have a healthy running cluster with the right resources capacity to
hold the workload. The Hub Cluster needs sufficient CPU and Memory resources.

## Run the scenario

### Bootstrap

Part 01 of the scenario focusses on the setup a Red
Hat Advanced Cluster Management Cluster from which a new Managed (by RHACM)
OpenShift Cluster is deployed. This setup is based on a Hub Spoke model
architecture and sets the stage for some nice real world use-cases.

Requirements:
- Ensure you have a basic/vanilla running OpenShift Cluster.
- Ensure you have a login credentials for the OpenShift Cluster.
- Ensure you have a login session with the OpenShift Cluster.
- Ensure you privileged (cluster-admin) user access to the OpenShift Cluster.
- Ensure you have access to an AWS account, permission and credentials.
- Ensure you have a proper working environment with required the tools and
  utilities.

Run:

```shell
$ ./scenarios/uc01-cluster-as-a-service/bootstrap-demo-part-01.sh
```

### Initialize demo

Part 02 of this scenario is to have an initial starting point. This will setup
the ArgoCD applications as the base ground of the demo.

```shell
$ ./scenarios/uc01-cluster-as-a-service/demo-initialize.sh
```

## Demo storyline

- Go to the "demo-pipelines" namespace and investigate the pipeline 'deploy-aws-cluster".
- Run the "deploy-aws-cluster" pipeline.
- Check the task outputs.
- Check the RHACM Cluster infrastructure overview.
- Wait for the new OpenShift Cluster on AWS to finish deployment.
