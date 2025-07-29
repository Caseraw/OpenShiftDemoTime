# Demo Q&A

## Questions

(Q) Will cloud-init be sufficient as an automation mechanism for the Virtual Machines?
(A) cloud-init is fine for using it as the initial setup right after boot. However, it does not suffice as a long term automation utility. Having tools such as Ansible with the Ansible Automation Platform will take you the extra miles in terms of Life Cycle Management (LCM) such as regular maintenance, configuration, additional integrations and updates.

(Q) Can a NetworkPolicy replace my Firewalls?
(A) No, it can not. It's always important to have a good security posture connectivity wise. Think of Enterprise grade Firewalling within the Organization's infrastructure using Enterprise grade hardware and software. Additionally it's also good to have Firewalls configured within the Virtual Machines on the Operating System level. Platform wise, next to the built-in Secure Connectivity features of OVN-Kubernetes (Software Defined Networking), the Kubernetes NetworkPolicies add the extra layer of security within a Namespace where the workload resides. Good Security practices always follow a multi-layered approach.

(Q) Do I have to use OpenShift Pipelines or can I also use other tools?
(A) OpenShift Pipelines is based on the Open Source project Tekton and provides for Continuous Integration (CI). This is just a means for automation, although highly recommended to use on OpenShift- or any other Kubernetes environment for that matter. It's OK to use other tools that provide for Continuous Integration (CI). What's important here, is that you use the right tool for the right job. This can be different depending on the situation.

(Q) Is it possible to have alerting setup for ArgoCD applications based on their Sync or Health status?
(A) Yes, ArgoCD exposes metrics that get scraped by Prometheus which is built in into the OpenShift Monitoring Solution. By creating the right PrometheusRules with the right Prometheus Queries and logic, the Alertmanager can be triggered to send notifications to any kind of receiver. Such as, e-mail, chat messenger, webhook etc.
Link: https://developers.redhat.com/blog/2025/07/24/create-additional-alerts-openshift-gitops#

