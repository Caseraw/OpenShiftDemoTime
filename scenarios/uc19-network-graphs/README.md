# Demo - Use Case 19 - Network Graphs

This scenario covers the exploration of the added value Red Hat Advanced Cluster
Security provides regarding Networking. It's scoped to only demonstrate some
Network features.

## Prerequisites

### RHACM - Hub Cluster

It all starts with having a healthy OpenShift Cluster (minimal compact cluster)
that is prepared with all the bells and whistles we need to start with. On top of
this Cluster we'll add the Operators and configuration components needed to be
treated as the Central Hub.

Run this script to turn your OpenShift Cluster into a RHACM Hub Cluster. Make
sure to have the following details to successfully deploy the setup.

- AWS Access ID
- AWS Access Key
- AWS Region
- Base domain of the running Cluster
- GUID of the demo environment
- OpenShift API endpoint
- OpenShift privileged user:
  - Username
  - Password
  - (or an already existing login session)

```shell
$ ./scenarios/demo-rhacm-cluster/bootstrap-demo.sh
```

> ⚠️ Make sure to only run this on the OpenShift Cluster that needs to be the
> RHACM Hub Cluster. Even though it's a shellscript, it's setup up in a way to
> resemble somewhat of an idempotency by stating desired configuration
> accompanied by some (chrono-)logical checkpoints.

When the Hub Cluster is setup you need to initialize the demo parts on it. Run
this script (with an active `oc` login session with the Hub Cluster).

```shell
$ ./scenarios/uc19-network-graphs/bootstrap-hub-cluster.sh
```

### AWS - Spoke Cluster

#### Deploy an AWS Spoke Cluster

Use the pipeline in the RHACM Hub Cluster to deploy an AWS Cluster.

Pipeline: `deploy-aws-cluster`
Namespace: `demo-pipelines`

Optionally deploy this resource to automatically kick of a `PipelineRun`.

```shell
oc apply -f - <<EOF
---
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: deploy-aws-cluster
  namespace: demo-pipelines
spec:
  pipelineRef:
    name: deploy-aws-cluster
  taskRunTemplate:
    serviceAccountName: pipeline
  timeouts:
    pipeline: 1h0m0s
EOF
```

#### Configure the AWS Spoke Cluster

The AWS cluster needs some setup. Get the OpenShift Credentials and have them ready or optionally
login with the `oc` CLI command before running the below command.

Run:

```shell
$ ./scenarios/uc19-network-graphs/bootstrap-spoke-cluster.sh
```

## Demo storyline

- Open ACM and show ACS Central on Hub Cluster.
  - Open ACS Central UI.
  - Explore Graphs.

...
...

Checking the PostgreSQL databse:
- `psql`
- `\c contacts`
- `\dt`
- `\d+ contacts`
- `select * form contacts;`

