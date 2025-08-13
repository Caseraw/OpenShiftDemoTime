# Demo - Use Case 15 - Hybrid

This scenario showcases the combination of regular cotainerized application
together with a high available MariaDB Galera Cluster and a Serverless variant
of the frontend application.

## Prerequisites

### UC19 Network Graphs

Everything relies on the environment set up like the scenario [UC19 Network
Graphs](../uc19-network-graphs/README.md). For more on the setup please checkout
the instructions.

### Set up a OCP Virt cluster

1. Deploy a new Cluster with ACM. Make sure to choose a metal instance for
   worker nodes.
2. Log in on the new OCP virt cluster.
3. Run this script: `scenarios/uc15-hybrid-workload/bootstrap-virt-cluster.sh`

## Demo storyline

- Explore the Virtual Machine setup, yaml, cloudinit.
- Show the MariaDB Galera replication.
- Show the current tables content of the database.

- Explore the image build.
- Open the Deployment web app.
    - Add some data.
- Open the Serverless web app.
    - Add some data.
- Show the table contents in the DB.

- Stop 1 GaleraDB VM.
- Show DB resiliency.
