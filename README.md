# OpenShift Demo Time

This repository contains the foundation to setup proper staged environments for Demonstrations and even Proof of Concept environments.

## Setup workspace

To start working with this repository you'll need a good foundation to work from. It's primarily based on VSCode Devcontainers and initiated with files in the `.devcontainer` directory in the root of this project. Make sure you have a proper starting point else you'll face challenges with and the lack of tools and CLI utilities will make your life a lot more difficult. There are other alternatives such as using a [Devfile](https://devfile.io/), on you localhost or just a regular Virtual Machine. All of the tools, utilities, packages and dependencies are described in the `.devcontainer` directory in the root of this project.

## Demo scenarios

Go ahead and bootstrap a demo environment located in the path: `<project root>/scenarios/<demo folder name>`.

Here's an example of a Demo Scenario: [Demo Hybrid Workload](/scenarios/demo-rhacm-hybrid-workload/README.md)

### Run a scenario

Each scenario is different so it's important to read about the scenario details before you try it out.

For example:

```shell
$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-01.sh
... output omitted ...
... output omitted ...
... output omitted ...

$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-02.sh
... output omitted ...
... output omitted ...
... output omitted ...
```

