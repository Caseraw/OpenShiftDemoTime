# Demo - Hybrid workload

This scenario starts off with an OpenShift Cluster on AWS including AWS account
credentials and permissions.

## Prerequisites

Make sure to have a healthy running cluster with the right resources capacity to
hold the workload. The Hub Cluster needs sufficient CPU and Memory resources.
The Virtualization Cluster (Spoke Cluster) will have to be able to carry the
required Operators, Control plane load as wel as being able to hold a number of
Virtual Machines and other Application Deployments required for the Scenario to
demonstrate.

## Run the scenario

### Part 1

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
$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-01.sh
```

### Part 2

Part 02 of this scenario deals with setting up the OpenShift Virtualization
Cluster on AWS managed by the Red Hat Advanced Cluster Management installed on
our Hub Cluster.

```shell
$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-02.sh
```

### Part 3

Part 03 of this scenario deals with setting up the following components on the
newly deployed cluster:
- OpenShift Local Storage Operator.
- OpenShift Data Foundation Operator.
- OpenShift Virtualization Cluster.
- OpenShift Serverless.
- OpenShift GitOps.
- OpenShift Pipelines.

Requirements:
- Ensure you have a basic/vanilla running OpenShift Cluster just deployed by the
  Part 2 of the scenarios.
- Ensure you have a login credentials for the OpenShift Cluster.
- Ensure you have a login session with the OpenShift Cluster.
- Ensure you privileged (cluster-admin) user access to the OpenShift Cluster.

Run:

```shell
$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-03.sh
```

### Part 4

Part 04 of this scenario deals with deploying the first ArgoCD Applications to
initiate with.

Run:

```shell
$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-04.sh
```
