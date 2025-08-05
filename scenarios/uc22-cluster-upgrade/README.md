# Demo - Use Case 22 - Cluster upgrade

This scenario is all about showing the experience of upgrading a cluster to a
new version from both the RHACM (hub) as well as the managed cluster (spoke)
point of view. While going through the upgrade well also be running an example
application to demonstrate the seamless (uninterrupted) effect on regular
application workload while the OpenShift Cluster is being upgraded.

## Prerequisites

Make sure to have a healthy running cluster with the right resources capacity to
hold the workload. It's depended on a Hub-Spoke model in which the Spoke Cluster
gets upgraded. The following has to be set in place.

- Follow the Use Case 01 (Cluster as a Service) setup.
- Follow the Use Case 01 (Cluster as a Service) storyline and spin up a new
  Spoke Cluster.

If not done already, login on the Hub cluster and run:

```shell
$ ./scenarios/uc01-cluster-as-a-service/bootstrap-demo-part-01.sh
```

## Run the scenario

### Bootstrap

Part 01 of the scenario focusses on the setup of the OpenShift Spoke Cluster. It
needs some initial configuration and setup in order to work properly.

Log in on the OpenShift Spoke Cluster and run:

```shell
$ ./scenarios/uc22-cluster-upgrade/bootstrap-demo-part-01.sh
```

### Initialize demo

Part 02 of this scenario is to have an initial starting point. This will setup
the ArgoCD applications as the base ground of the demo.

```shell
$ ./scenarios/uc22-cluster-upgrade/demo-initialize.sh
```

## Demo storyline

- Explore the example application "backend-pod-spot" (on the Spoke Cluster) and "frontend-pod-spot" (on
  the Hub cluster).
- Explore the Spoke cluster version, alongside the CVO configuration and
  upgrade path.
- Kickoff the upgrade from RHACM.
- Keep monitoring the upgrade from all points of view (Hub, Spoke, Example
  application).
