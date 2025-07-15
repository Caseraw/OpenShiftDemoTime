# Demo - Hybrid workload

This scenario starts off with an OpenShift Cluster on AWS including AWS account
credentials and permissions.

Part 01 of the scenario focusses on the setup a Red
Hat Advanced Cluster Management Cluster from which a new Managed (by RHACM)
OpenShift Cluster is deployed. This setup is based on a Hub Spoke model
architecture and sets the stage for some nice real world use-cases.

Part 02 of this scenario deals with setting up the following components on the
newly deployed cluster:
- OpenShift Local Storage Operator.
- OpenShift Data Foundation Operator.
- OpenShift Virtualization Cluster.
- OpenShift Serverless.
- OpenShift Pipelines.

## Run the scenario

### Part 1

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

Requirements:
- Ensure you have a basic/vanilla running OpenShift Cluster just deployed by the Part 1 of the scenarios.
- Ensure you have a login credentials for the OpenShift Cluster.
- Ensure you have a login session with the OpenShift Cluster.
- Ensure you privileged (cluster-admin) user access to the OpenShift Cluster.

Run:

```shell
$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-02.sh
```

## `bootstrap-demo-part-01.sh` output on ACM Cluster

```shell
[vscode@cee95e6949bb OpenShiftDemoTime]$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-01.sh 
[14-07-2025 19:15:20] INFO - Bootstrap - Perform the scenario prerequisites | ⏳
[14-07-2025 19:15:20] INFO - Script | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/setup.sh
[14-07-2025 19:15:20] INFO - Setting up | Credentials for AWS | ⏳
Enter AWS Access Key ID: XXXXXX
Enter AWS Secret Access Key: 
Enter AWS Region: eu-central-1
Enter OCP cluster base domain: sandbox2743.opentlc.com
Enter OCP cluster GUID: 8jmcs
[14-07-2025 19:15:43] WARNING - File already exists | Confirm to proceed...
[14-07-2025 19:15:43] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/bundle.env
Do you want to overwrite /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/bundle.env? (y/n): y
[14-07-2025 19:18:41] WARNING - File already exists | Confirm to proceed...
[14-07-2025 19:18:41] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/aws-cli.env
Do you want to overwrite /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/aws-cli.env? (y/n): y
[14-07-2025 19:18:43] INFO - Done | AWS CLI file created/updated
[14-07-2025 19:18:43] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/aws-cli.env
[14-07-2025 19:18:43] WARNING - File already exists | Confirm to proceed...
[14-07-2025 19:18:43] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/basedomain.env
Do you want to overwrite /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/basedomain.env? (y/n): y
[14-07-2025 19:18:44] INFO - Done | Base domain file created/updated
[14-07-2025 19:18:44] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/basedomain.env
[14-07-2025 19:18:44] WARNING - File already exists | Confirm to proceed...
[14-07-2025 19:18:44] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/accesskeyid.env
Do you want to overwrite /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/accesskeyid.env? (y/n): y
[14-07-2025 19:18:44] INFO - Done | Access key ID file created/updated
[14-07-2025 19:18:44] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/accesskeyid.env
[14-07-2025 19:18:44] WARNING - File already exists | Confirm to proceed...
[14-07-2025 19:18:44] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/secretaccesskey.env
Do you want to overwrite /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/secretaccesskey.env? (y/n): y
[14-07-2025 19:18:47] INFO - Done | Secret access key file created/updated
[14-07-2025 19:18:47] INFO - File | /workspaces/OpenShiftDemoTime/assets/byo/credentials-aws/secretaccesskey.env
[14-07-2025 19:18:47] INFO - Setup completed | ✅
[14-07-2025 19:18:47] INFO - Bootstrap - Perform the scenario prerequisites | Completed | ✅
[14-07-2025 19:18:47] INFO - Bootstrap - Login to OpenShift | ⏳
[14-07-2025 19:18:47] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/functions/login-on-openshift.sh
[14-07-2025 19:18:47] INFO - Logging in on an OpenShift Cluster | ⏳
[14-07-2025 19:18:52] INFO - Already logged into OpenShift cluster.
[14-07-2025 19:18:52] INFO - User | kube:admin
[14-07-2025 19:18:52] INFO - Cluster | https://api.cluster-8jmcs.8jmcs.sandbox2743.opentlc.com:6443
Do you want to log in again? (y/N): N
[14-07-2025 19:18:59] INFO - Keeping the existing session | Continuing execution...
[14-07-2025 19:18:59] INFO - Current user details
kube:admin
[14-07-2025 19:18:59] INFO - Current cluster
https://api.cluster-8jmcs.8jmcs.sandbox2743.opentlc.com:6443
default/api-cluster-8jmcs-8jmcs-sandbox2743-opentlc-com:6443/kube:admin
[14-07-2025 19:19:00] INFO - Logging in on an OpenShift Cluster | Completed | ✅
[14-07-2025 19:19:00] INFO - Bootstrap - Login to OpenShift | Completed | ✅
[14-07-2025 19:19:00] INFO - Bootstrap - Setup the RHACM Operator | ⏳
[14-07-2025 19:19:00] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-rhacm-operator/setup.sh
[14-07-2025 19:19:00] INFO - Installing Operator RHACM Operator | ⏳
[14-07-2025 19:19:00] INFO - Running Kustomize build...
namespace/open-cluster-management created
operatorgroup.operators.coreos.com/open-cluster-management-operator-group created
subscription.operators.coreos.com/advanced-cluster-management created
[14-07-2025 19:19:01] INFO - Wait for Operator to be ready
error: no matching resources found
[14-07-2025 19:19:01] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 0/1800 sec. timeout...
error: no matching resources found
[14-07-2025 19:19:12] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 11/1800 sec. timeout...
clusterserviceversion.operators.coreos.com/advanced-cluster-management.v2.13.3 condition met
[14-07-2025 19:19:36] INFO - Wait for Operator to be ready
pod/multiclusterhub-operator-7ff5c77bcc-cm4fl condition met
pod/multiclusterhub-operator-7ff5c77bcc-cm4fl condition met
pod/multiclusterhub-operator-7ff5c77bcc-dkr47 condition met
pod/multiclusterhub-operator-7ff5c77bcc-dkr47 condition met
[14-07-2025 19:19:39] INFO - Installing Operator RHACM Operator | Completed | ✅
[14-07-2025 19:19:39] INFO - Bootstrap - Setup the RHACM Operator | Completed | ✅
[14-07-2025 19:19:39] INFO - Bootstrap - Setup the MultiClusterHub in RHACM | ⏳
[14-07-2025 19:19:39] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-rhacm-multiclusterhub/setup.sh
[14-07-2025 19:19:39] INFO - Deploy the MultiClusterHub in RHACM | ⏳
[14-07-2025 19:19:39] INFO - Running Kustomize build...
multiclusterhub.operator.open-cluster-management.io/multiclusterhub created
[14-07-2025 19:19:40] INFO - Wait for Operator to be ready
clusterserviceversion.operators.coreos.com/advanced-cluster-management.v2.13.3 condition met
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:20:11] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 31/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:20:51] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 71/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:21:32] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 112/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:22:12] WARNING - Command failed | Retrying | Attempt 4, infinite retries, 10 sec. interval, 152/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:22:53] WARNING - Command failed | Retrying | Attempt 5, infinite retries, 10 sec. interval, 193/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:23:33] WARNING - Command failed | Retrying | Attempt 6, infinite retries, 10 sec. interval, 233/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:24:14] WARNING - Command failed | Retrying | Attempt 7, infinite retries, 10 sec. interval, 274/1800 sec. timeout...
error: timed out waiting for the condition on multiclusterhubs/multiclusterhub
[14-07-2025 19:24:54] WARNING - Command failed | Retrying | Attempt 8, infinite retries, 10 sec. interval, 314/1800 sec. timeout...
multiclusterhub.operator.open-cluster-management.io/multiclusterhub condition met
[14-07-2025 19:25:10] INFO - Wait for Workload to be ready
pod/acm-cli-downloads-99576bb9c-lsqz8 condition met
pod/acm-cli-downloads-99576bb9c-lsqz8 condition met
pod/cluster-permission-6dd9c78b57-c9lm4 condition met
pod/cluster-permission-6dd9c78b57-c9lm4 condition met
pod/console-chart-console-v2-6fbc75785c-fbpss condition met
pod/console-chart-console-v2-6fbc75785c-fbpss condition met
pod/grc-policy-addon-controller-7cf6f66fb7-ndm97 condition met
pod/grc-policy-addon-controller-7cf6f66fb7-ndm97 condition met
pod/grc-policy-propagator-5db5b98b58-g2nwt condition met
pod/grc-policy-propagator-5db5b98b58-g2nwt condition met
pod/insights-client-58f774df49-b4kgh condition met
pod/insights-client-58f774df49-b4kgh condition met
pod/insights-metrics-56c8b9b987-w2jhc condition met
pod/insights-metrics-56c8b9b987-w2jhc condition met
pod/klusterlet-addon-controller-v2-6b6c4df9f4-8xdt7 condition met
pod/klusterlet-addon-controller-v2-6b6c4df9f4-8xdt7 condition met
pod/multicluster-integrations-59bcf7779-vxvcr condition met
pod/multicluster-integrations-59bcf7779-vxvcr condition met
pod/multicluster-observability-operator-7b46b67c5-vfff9 condition met
pod/multicluster-observability-operator-7b46b67c5-vfff9 condition met
pod/multicluster-operators-application-58c8dd59f4-c5nch condition met
pod/multicluster-operators-application-58c8dd59f4-c5nch condition met
pod/multicluster-operators-channel-5ff9cf57db-9tj2b condition met
pod/multicluster-operators-channel-5ff9cf57db-9tj2b condition met
pod/multicluster-operators-hub-subscription-67b4446fb8-mc8xm condition met
pod/multicluster-operators-hub-subscription-67b4446fb8-mc8xm condition met
pod/multicluster-operators-standalone-subscription-5cb99c5b89-9ng2z condition met
pod/multicluster-operators-standalone-subscription-5cb99c5b89-9ng2z condition met
pod/multicluster-operators-subscription-report-84b695d557-hdsjj condition met
pod/multicluster-operators-subscription-report-84b695d557-hdsjj condition met
pod/multiclusterhub-operator-7ff5c77bcc-cm4fl condition met
pod/multiclusterhub-operator-7ff5c77bcc-cm4fl condition met
pod/multiclusterhub-operator-7ff5c77bcc-dkr47 condition met
pod/multiclusterhub-operator-7ff5c77bcc-dkr47 condition met
pod/search-api-7c78446794-hxm4m condition met
pod/search-api-7c78446794-hxm4m condition met
pod/search-collector-677b48f498-kssxm condition met
pod/search-collector-677b48f498-kssxm condition met
pod/search-indexer-864c664797-fw9kl condition met
pod/search-indexer-864c664797-fw9kl condition met
pod/search-postgres-776d8f9dd7-gtwjz condition met
pod/search-postgres-776d8f9dd7-gtwjz condition met
pod/search-v2-operator-controller-manager-867fd59985-nqpt9 condition met
pod/search-v2-operator-controller-manager-867fd59985-nqpt9 condition met
pod/submariner-addon-77674c98f8-rkshp condition met
pod/submariner-addon-77674c98f8-rkshp condition met
pod/volsync-addon-controller-cf8db6599-fmg2z condition met
pod/volsync-addon-controller-cf8db6599-fmg2z condition met
[14-07-2025 19:25:38] INFO - Deploy the MultiClusterHub in RHACM | Completed | ✅
[14-07-2025 19:25:38] INFO - Bootstrap - Setup the MultiClusterHub in RHACM | Completed | ✅
[14-07-2025 19:25:38] INFO - Bootstrap - Setup the MultiClusterObservability in RHACM | ⏳
[14-07-2025 19:25:38] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-rhacm-multicluster-observability/setup.sh
[14-07-2025 19:25:38] INFO - Deploy the MultiClusterObservability in RHACM | ⏳
[14-07-2025 19:25:38] INFO - Setup AWS CLI configuration
[14-07-2025 19:25:40] INFO - Create AWS S3 bucket | s3://grafana-8jmcs
make_bucket: grafana-8jmcs
[14-07-2025 19:25:42] INFO - Running Kustomize build...
namespace/open-cluster-management-observability created
secret/multiclusterhub-operator-pull-secret created
multiclusterobservability.observability.open-cluster-management.io/observability created
[14-07-2025 19:25:42] INFO - Create thanos-object-storage secret
secret/thanos-object-storage created
[14-07-2025 19:25:43] INFO - Deploy the MultiClusterObservability in RHACM | Completed | ✅
[14-07-2025 19:25:43] INFO - Bootstrap - Setup the MultiClusterObservability in RHACM | Completed | ✅
[14-07-2025 19:25:43] INFO - Bootstrap - Setup the OpenShift GitOps Operator | ⏳
[14-07-2025 19:25:43] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-gitops/setup.sh
[14-07-2025 19:25:43] INFO - Install the Red Hat GitOps Operator | ⏳
[14-07-2025 19:25:43] INFO - Running Kustomize build...
namespace/openshift-gitops-operator created
operatorgroup.operators.coreos.com/openshift-gitops-operator created
subscription.operators.coreos.com/openshift-gitops-operator created
[14-07-2025 19:25:43] INFO - Check OpenShift GitOps ArgoCD Operator and Instance to be ready...
error: no matching resources found
[14-07-2025 19:25:44] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/1800 sec. timeout...
error: no matching resources found
[14-07-2025 19:25:54] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 11/1800 sec. timeout...
clusterserviceversion.operators.coreos.com/openshift-gitops-operator.v1.16.1 condition met
clusterserviceversion.operators.coreos.com/openshift-gitops-operator.v1.16.1 condition met
argocd.argoproj.io/openshift-gitops condition met
argocd.argoproj.io/openshift-gitops condition met
argocd.argoproj.io/openshift-gitops condition met
argocd.argoproj.io/openshift-gitops condition met
argocd.argoproj.io/openshift-gitops condition met
argocd.argoproj.io/openshift-gitops condition met
argocd.argoproj.io/openshift-gitops condition met
[14-07-2025 19:27:21] INFO - Check for OpenShift GitOps ArgoCD workload to be ready...
pod/cluster-67f6d65887-slrnf condition met
pod/cluster-67f6d65887-slrnf condition met
pod/gitops-plugin-7bfb8db8dd-fsntx condition met
pod/gitops-plugin-7bfb8db8dd-fsntx condition met
pod/openshift-gitops-application-controller-0 condition met
pod/openshift-gitops-application-controller-0 condition met
pod/openshift-gitops-applicationset-controller-756c86fcd8-q5ggm condition met
pod/openshift-gitops-applicationset-controller-756c86fcd8-q5ggm condition met
pod/openshift-gitops-dex-server-9b658db79-xdtlr condition met
pod/openshift-gitops-dex-server-9b658db79-xdtlr condition met
pod/openshift-gitops-redis-6c9d8c9-76k6t condition met
pod/openshift-gitops-redis-6c9d8c9-76k6t condition met
pod/openshift-gitops-repo-server-56c6ffcf9b-bwd7x condition met
pod/openshift-gitops-repo-server-56c6ffcf9b-bwd7x condition met
pod/openshift-gitops-server-5dbdddcc4f-gp465 condition met
pod/openshift-gitops-server-5dbdddcc4f-gp465 condition met
[14-07-2025 19:27:29] INFO - Install the Red Hat GitOps Operator | Completed | ✅
[14-07-2025 19:27:29] INFO - Bootstrap - Setup the OpenShift GitOps Operator | Completed | ✅
[14-07-2025 19:27:29] INFO - Bootstrap - Setup the GitOps Cluster for RHACM | ⏳
[14-07-2025 19:27:29] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-rhacm-gitops-cluster/setup.sh
[14-07-2025 19:27:29] INFO - Install the GitOps Cluster for RHACM | ⏳
[14-07-2025 19:27:29] INFO - Running Kustomize build...
gitopscluster.apps.open-cluster-management.io/rhacm-gitops-cluster created
placement.cluster.open-cluster-management.io/rhacm-gitops-cluster-placement created
managedclustersetbinding.cluster.open-cluster-management.io/default created
[14-07-2025 19:27:30] INFO - Install the GitOps Cluster for RHACM | Completed | ✅
[14-07-2025 19:27:30] INFO - Bootstrap - Setup the GitOps Cluster for RHACM | Completed | ✅
[14-07-2025 19:27:30] INFO - Bootstrap - Setup the OpenShift Pipelines Operator | ⏳
[14-07-2025 19:27:30] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-pipelines/setup.sh
[14-07-2025 19:27:30] INFO - Install the OpenShift Pipelines Operator | ⏳
[14-07-2025 19:27:30] INFO - Running Kustomize build...
subscription.operators.coreos.com/openshift-pipelines-operator-rh created
[14-07-2025 19:27:31] INFO - Wait for Operator to be ready
clusterserviceversion.operators.coreos.com/openshift-gitops-operator.v1.16.1 condition met
error: the server doesn't have a resource type "tektonconfigs"
[14-07-2025 19:27:32] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/1800 sec. timeout...
error: the server doesn't have a resource type "tektonconfigs"
[14-07-2025 19:27:42] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 11/1800 sec. timeout...
config               
[14-07-2025 19:27:57] INFO - Wait for Workload to be ready
pod/openshift-pipelines-operator-8945758c7-tsvfb condition met
pod/openshift-pipelines-operator-8945758c7-tsvfb condition met
[14-07-2025 19:27:58] INFO - Install the OpenShift Pipelines Operator | Completed | ✅
[14-07-2025 19:27:58] INFO - Bootstrap - Setup the OpenShift Console configuration | Completed | ✅
[14-07-2025 19:27:58] INFO - Bootstrap - Setup the OpenShift Console configuration  | ⏳
[14-07-2025 19:27:58] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-console-config/setup.sh
[14-07-2025 19:27:58] INFO - Configure Cluster Web Console | ⏳
[14-07-2025 19:27:58] INFO - Running Kustomize build...
Warning: resource consoles/cluster is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply should only be used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
console.operator.openshift.io/cluster configured
[14-07-2025 19:27:59] INFO - Configure Cluster Web Console | Completed | ✅
[14-07-2025 19:27:59] INFO - Bootstrap - Setup the OpenShift Console configuration | Completed | ✅
[14-07-2025 19:27:59] INFO - Bootstrap - Deploy AWS Credentials in RHACM | ⏳
[14-07-2025 19:27:59] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-rhacm-credentials-aws/setup.sh
[14-07-2025 19:27:59] INFO - Deploy AWS Credentials | Advanced Cluster Management for Kubernetes | ⏳
[14-07-2025 19:28:00] INFO - Running Kustomize build...
secret/aws created
[14-07-2025 19:28:00] INFO - Deploy AWS Credentials | Completed | ✅
[14-07-2025 19:28:00] INFO - Bootstrap - Deploy AWS Credentials in RHACM | Completed | ✅
[14-07-2025 19:28:00] INFO - Bootstrap - Deploy the Red Hat Virtualization Cluster on AWS | ⏳
[14-07-2025 19:28:00] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-rhacm-deploy-aws-cluster/setup.sh
[14-07-2025 19:28:00] INFO - Deploy new AWS Cluster | ⏳
[14-07-2025 19:28:00] INFO - Deploying cluster | aws-cluster-01
namespace/aws-cluster-01 created
clusterdeployment.hive.openshift.io/aws-cluster-01 created
managedcluster.cluster.open-cluster-management.io/aws-cluster-01 created
machinepool.hive.openshift.io/aws-cluster-01-worker created
secret/aws-cluster-01-pull-secret created
secret/aws-cluster-01-install-config created
secret/aws-cluster-01-ssh-private-key created
secret/aws-cluster-01-aws-creds created
klusterletaddonconfig.agent.open-cluster-management.io/aws-cluster-01 created
[14-07-2025 19:28:07] INFO - Deployed successfully! | Cluster aws-cluster-01
[14-07-2025 19:28:07] INFO - Wait new Cluster to be ready...
error: no matching resources found
[14-07-2025 19:28:08] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:28:48] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 41/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:29:29] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 82/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:30:09] WARNING - Command failed | Retrying | Attempt 4, infinite retries, 10 sec. interval, 122/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:30:50] WARNING - Command failed | Retrying | Attempt 5, infinite retries, 10 sec. interval, 163/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:31:30] WARNING - Command failed | Retrying | Attempt 6, infinite retries, 10 sec. interval, 203/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:32:10] WARNING - Command failed | Retrying | Attempt 7, infinite retries, 10 sec. interval, 243/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:32:51] WARNING - Command failed | Retrying | Attempt 8, infinite retries, 10 sec. interval, 284/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:33:31] WARNING - Command failed | Retrying | Attempt 9, infinite retries, 10 sec. interval, 324/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:34:12] WARNING - Command failed | Retrying | Attempt 10, infinite retries, 10 sec. interval, 365/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:34:52] WARNING - Command failed | Retrying | Attempt 11, infinite retries, 10 sec. interval, 405/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:35:33] WARNING - Command failed | Retrying | Attempt 12, infinite retries, 10 sec. interval, 446/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:36:13] WARNING - Command failed | Retrying | Attempt 13, infinite retries, 10 sec. interval, 486/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:36:54] WARNING - Command failed | Retrying | Attempt 14, infinite retries, 10 sec. interval, 527/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:37:34] WARNING - Command failed | Retrying | Attempt 15, infinite retries, 10 sec. interval, 567/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:38:15] WARNING - Command failed | Retrying | Attempt 16, infinite retries, 10 sec. interval, 607/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:38:55] WARNING - Command failed | Retrying | Attempt 17, infinite retries, 10 sec. interval, 648/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:39:35] WARNING - Command failed | Retrying | Attempt 18, infinite retries, 10 sec. interval, 688/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:40:16] WARNING - Command failed | Retrying | Attempt 19, infinite retries, 10 sec. interval, 729/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:40:56] WARNING - Command failed | Retrying | Attempt 20, infinite retries, 10 sec. interval, 769/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:41:37] WARNING - Command failed | Retrying | Attempt 21, infinite retries, 10 sec. interval, 810/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:42:17] WARNING - Command failed | Retrying | Attempt 22, infinite retries, 10 sec. interval, 850/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:42:58] WARNING - Command failed | Retrying | Attempt 23, infinite retries, 10 sec. interval, 891/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:43:38] WARNING - Command failed | Retrying | Attempt 24, infinite retries, 10 sec. interval, 931/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:44:19] WARNING - Command failed | Retrying | Attempt 25, infinite retries, 10 sec. interval, 972/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:44:59] WARNING - Command failed | Retrying | Attempt 26, infinite retries, 10 sec. interval, 1012/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:45:40] WARNING - Command failed | Retrying | Attempt 27, infinite retries, 10 sec. interval, 1053/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:46:20] WARNING - Command failed | Retrying | Attempt 28, infinite retries, 10 sec. interval, 1093/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:47:00] WARNING - Command failed | Retrying | Attempt 29, infinite retries, 10 sec. interval, 1133/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:47:41] WARNING - Command failed | Retrying | Attempt 30, infinite retries, 10 sec. interval, 1174/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:48:21] WARNING - Command failed | Retrying | Attempt 31, infinite retries, 10 sec. interval, 1214/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:49:02] WARNING - Command failed | Retrying | Attempt 32, infinite retries, 10 sec. interval, 1255/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:49:42] WARNING - Command failed | Retrying | Attempt 33, infinite retries, 10 sec. interval, 1295/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:50:23] WARNING - Command failed | Retrying | Attempt 34, infinite retries, 10 sec. interval, 1336/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:51:03] WARNING - Command failed | Retrying | Attempt 35, infinite retries, 10 sec. interval, 1376/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:51:44] WARNING - Command failed | Retrying | Attempt 36, infinite retries, 10 sec. interval, 1417/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:52:24] WARNING - Command failed | Retrying | Attempt 37, infinite retries, 10 sec. interval, 1457/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:53:05] WARNING - Command failed | Retrying | Attempt 38, infinite retries, 10 sec. interval, 1497/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:53:45] WARNING - Command failed | Retrying | Attempt 39, infinite retries, 10 sec. interval, 1538/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:54:25] WARNING - Command failed | Retrying | Attempt 40, infinite retries, 10 sec. interval, 1578/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:55:06] WARNING - Command failed | Retrying | Attempt 41, infinite retries, 10 sec. interval, 1619/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:55:46] WARNING - Command failed | Retrying | Attempt 42, infinite retries, 10 sec. interval, 1659/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:56:27] WARNING - Command failed | Retrying | Attempt 43, infinite retries, 10 sec. interval, 1700/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:57:07] WARNING - Command failed | Retrying | Attempt 44, infinite retries, 10 sec. interval, 1740/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:57:48] WARNING - Command failed | Retrying | Attempt 45, infinite retries, 10 sec. interval, 1781/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:58:28] WARNING - Command failed | Retrying | Attempt 46, infinite retries, 10 sec. interval, 1821/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:59:09] WARNING - Command failed | Retrying | Attempt 47, infinite retries, 10 sec. interval, 1862/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 19:59:49] WARNING - Command failed | Retrying | Attempt 48, infinite retries, 10 sec. interval, 1902/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:00:30] WARNING - Command failed | Retrying | Attempt 49, infinite retries, 10 sec. interval, 1943/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:01:10] WARNING - Command failed | Retrying | Attempt 50, infinite retries, 10 sec. interval, 1983/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:01:51] WARNING - Command failed | Retrying | Attempt 51, infinite retries, 10 sec. interval, 2024/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:02:31] WARNING - Command failed | Retrying | Attempt 52, infinite retries, 10 sec. interval, 2064/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:03:12] WARNING - Command failed | Retrying | Attempt 53, infinite retries, 10 sec. interval, 2105/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:03:52] WARNING - Command failed | Retrying | Attempt 54, infinite retries, 10 sec. interval, 2145/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:04:32] WARNING - Command failed | Retrying | Attempt 55, infinite retries, 10 sec. interval, 2185/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:05:13] WARNING - Command failed | Retrying | Attempt 56, infinite retries, 10 sec. interval, 2226/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:05:53] WARNING - Command failed | Retrying | Attempt 57, infinite retries, 10 sec. interval, 2266/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:06:34] WARNING - Command failed | Retrying | Attempt 58, infinite retries, 10 sec. interval, 2307/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:07:14] WARNING - Command failed | Retrying | Attempt 59, infinite retries, 10 sec. interval, 2347/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:07:55] WARNING - Command failed | Retrying | Attempt 60, infinite retries, 10 sec. interval, 2388/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:08:35] WARNING - Command failed | Retrying | Attempt 61, infinite retries, 10 sec. interval, 2428/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:09:16] WARNING - Command failed | Retrying | Attempt 62, infinite retries, 10 sec. interval, 2469/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:09:56] WARNING - Command failed | Retrying | Attempt 63, infinite retries, 10 sec. interval, 2509/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:10:37] WARNING - Command failed | Retrying | Attempt 64, infinite retries, 10 sec. interval, 2549/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:11:17] WARNING - Command failed | Retrying | Attempt 65, infinite retries, 10 sec. interval, 2590/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:11:57] WARNING - Command failed | Retrying | Attempt 66, infinite retries, 10 sec. interval, 2630/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:12:38] WARNING - Command failed | Retrying | Attempt 67, infinite retries, 10 sec. interval, 2671/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:13:18] WARNING - Command failed | Retrying | Attempt 68, infinite retries, 10 sec. interval, 2711/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:13:59] WARNING - Command failed | Retrying | Attempt 69, infinite retries, 10 sec. interval, 2752/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:14:39] WARNING - Command failed | Retrying | Attempt 70, infinite retries, 10 sec. interval, 2792/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:15:20] WARNING - Command failed | Retrying | Attempt 71, infinite retries, 10 sec. interval, 2833/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:16:00] WARNING - Command failed | Retrying | Attempt 72, infinite retries, 10 sec. interval, 2873/3600 sec. timeout...
error: timed out waiting for the condition on pods/aws-cluster-01-0-5r46r-provision-jkss7
[14-07-2025 20:16:41] WARNING - Command failed | Retrying | Attempt 73, infinite retries, 10 sec. interval, 2914/3600 sec. timeout...
pod/aws-cluster-01-0-5r46r-provision-jkss7 condition met
job.batch/aws-cluster-01-0-5r46r-provision condition met
[14-07-2025 20:17:15] INFO - Deploy new AWS Cluster | Completed | ✅
[14-07-2025 20:17:15] INFO - Bootstrap - Deploy the Red Hat Virtualization Cluster on AWS | Completed | ✅
```

## `bootstrap-demo-part-01.sh` output on Managed AWS Cluster

```shell
[vscode@cee95e6949bb OpenShiftDemoTime]$ ./scenarios/demo-rhacm-hybrid-workload/bootstrap-demo-part-02.sh 
[14-07-2025 21:12:00] INFO - Bootstrap - Install OpenShift Local Storage Operator | ⏳
[14-07-2025 21:12:00] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-local-storage/setup.sh
[14-07-2025 21:12:00] INFO - Install OpenShift Local Storage Operator | ⏳
[14-07-2025 21:12:00] INFO - Labeling storage nodes
node/ip-10-0-31-232.ec2.internal labeled
node/ip-10-0-58-28.ec2.internal labeled
node/ip-10-0-81-181.ec2.internal labeled
[14-07-2025 21:12:04] INFO - Running Kustomize build part 01...
namespace/openshift-local-storage created
operatorgroup.operators.coreos.com/openshift-local-storage-operator-group created
subscription.operators.coreos.com/local-storage-operator created
[14-07-2025 21:12:05] INFO - Wait for Operator to be ready
error: no matching resources found
[14-07-2025 21:12:06] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/1800 sec. timeout...
error: no matching resources found
[14-07-2025 21:12:17] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 12/1800 sec. timeout...
clusterserviceversion.operators.coreos.com/local-storage-operator.v4.19.0-202507011209 condition met
[14-07-2025 21:12:28] INFO - Running Kustomize build part 02...
localvolumediscovery.local.storage.openshift.io/auto-discover-devices created
localvolumeset.local.storage.openshift.io/local-storage-odf created
[14-07-2025 21:12:30] INFO - Wait for Operator configuration to be ready
localvolumediscovery.local.storage.openshift.io/auto-discover-devices condition met
[14-07-2025 21:12:31] INFO - Wait for Workload to be ready
pod/diskmaker-discovery-gb2dl condition met
pod/diskmaker-discovery-gb2dl condition met
pod/diskmaker-discovery-v6spl condition met
pod/diskmaker-discovery-v6spl condition met
pod/diskmaker-discovery-zc224 condition met
pod/diskmaker-discovery-zc224 condition met
pod/diskmaker-manager-nns72 condition met
pod/diskmaker-manager-nns72 condition met
pod/diskmaker-manager-qdcbc condition met
pod/diskmaker-manager-qdcbc condition met
pod/diskmaker-manager-tbj8n condition met
pod/diskmaker-manager-tbj8n condition met
pod/local-storage-operator-584d555466-t6cth condition met
pod/local-storage-operator-584d555466-t6cth condition met
[14-07-2025 21:12:52] INFO - Install OpenShift Local Storage Operator | Completed | ✅
[14-07-2025 21:12:52] INFO - Bootstrap - Install OpenShift Local Storage Operator | Completed | ✅
[14-07-2025 21:12:52] INFO - Bootstrap - Install OpenShift Data Foundation Operator | ⏳
[14-07-2025 21:12:52] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-storage/setup.sh
[14-07-2025 21:12:52] INFO - Install OpenShift Data Foundation Operator | ⏳
[14-07-2025 21:12:52] INFO - Running Kustomize build part 01...
namespace/openshift-storage created
operatorgroup.operators.coreos.com/openshift-storage-operator-group created
subscription.operators.coreos.com/odf-operator created
[14-07-2025 21:12:53] INFO - Wait for Operator to be ready
error: no matching resources found
[14-07-2025 21:12:54] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/odf-operator.v4.18.6-rhodf
[14-07-2025 21:13:34] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 41/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/odf-operator.v4.18.6-rhodf
[14-07-2025 21:14:15] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 82/3600 sec. timeout...
clusterserviceversion.operators.coreos.com/odf-operator.v4.18.6-rhodf condition met
error: timed out waiting for the condition on clusterserviceversions/ocs-client-operator.v4.18.6-rhodf
[14-07-2025 21:15:09] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 30/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/ocs-client-operator.v4.18.6-rhodf
[14-07-2025 21:15:50] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 71/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/ocs-client-operator.v4.18.6-rhodf
[14-07-2025 21:16:30] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 111/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/ocs-client-operator.v4.18.6-rhodf
[14-07-2025 21:17:11] WARNING - Command failed | Retrying | Attempt 4, infinite retries, 10 sec. interval, 152/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/ocs-client-operator.v4.18.6-rhodf
[14-07-2025 21:17:51] WARNING - Command failed | Retrying | Attempt 5, infinite retries, 10 sec. interval, 192/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/ocs-client-operator.v4.18.6-rhodf
[14-07-2025 21:18:32] WARNING - Command failed | Retrying | Attempt 6, infinite retries, 10 sec. interval, 233/3600 sec. timeout...
clusterserviceversion.operators.coreos.com/ocs-client-operator.v4.18.6-rhodf condition met
[14-07-2025 21:19:02] INFO - Running Kustomize build part 02...
storagecluster.ocs.openshift.io/ocs-storagecluster created
[14-07-2025 21:19:04] INFO - Wait for Operators and configuration to be ready
clusterserviceversion.operators.coreos.com/cephcsi-operator.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/mcg-operator.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/ocs-operator.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/odf-csi-addons-operator.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/odf-dependencies.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/odf-prometheus-operator.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/recipe.v4.18.6-rhodf condition met
clusterserviceversion.operators.coreos.com/rook-ceph-operator.v4.18.6-rhodf condition met
error: timed out waiting for the condition on storageclusters/ocs-storagecluster
[14-07-2025 21:19:43] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 31/3600 sec. timeout...
error: timed out waiting for the condition on storageclusters/ocs-storagecluster
[14-07-2025 21:20:23] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 71/3600 sec. timeout...
error: timed out waiting for the condition on storageclusters/ocs-storagecluster
[14-07-2025 21:21:04] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 112/3600 sec. timeout...
error: timed out waiting for the condition on storageclusters/ocs-storagecluster
[14-07-2025 21:21:44] WARNING - Command failed | Retrying | Attempt 4, infinite retries, 10 sec. interval, 152/3600 sec. timeout...
storagecluster.ocs.openshift.io/ocs-storagecluster condition met
[14-07-2025 21:21:55] INFO - Wait for Workload etc. to be ready
storageclass.storage.k8s.io/local-storage-odf condition met
storageclass.storage.k8s.io/ocs-storagecluster-ceph-rbd condition met
storageclass.storage.k8s.io/ocs-storagecluster-cephfs condition met
storageclass.storage.k8s.io/openshift-storage.noobaa.io condition met
pod/rook-ceph-osd-0-645d48b75c-bgvl6 condition met
pod/rook-ceph-osd-1-66676d5ccc-k5s7h condition met
pod/rook-ceph-osd-10-79f9c57674-9kcmx condition met
pod/rook-ceph-osd-11-6c58b4bf9-4j648 condition met
pod/rook-ceph-osd-2-78fcbcd94-rnzwm condition met
pod/rook-ceph-osd-3-d467f8c5f-vxskh condition met
pod/rook-ceph-osd-4-84f785556-5n47s condition met
pod/rook-ceph-osd-5-678b7dd7f4-72rck condition met
pod/rook-ceph-osd-6-84ff576d7b-pg72q condition met
pod/rook-ceph-osd-7-7654fbbcbd-mx4cp condition met
pod/rook-ceph-osd-8-6f549d5c96-8hbg4 condition met
pod/rook-ceph-osd-9-7cf48f78ff-7dhdf condition met
[14-07-2025 21:22:03] INFO - Install OpenShift Data Foundation Operator | Completed | ✅
[14-07-2025 21:22:03] INFO - Bootstrap - Install OpenShift Data Foundation Operator | Completed | ✅
[14-07-2025 21:22:03] INFO - Bootstrap - Install OpenShift Virtualization Operator | ⏳
[14-07-2025 21:22:03] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-virtualization/setup.sh
[14-07-2025 21:22:03] INFO - Install OpenShift Virtualization Operator | ⏳
[14-07-2025 21:22:03] INFO - Running Kustomize build part 01...
namespace/openshift-cnv created
operatorgroup.operators.coreos.com/openshift-cnv-operator-group created
subscription.operators.coreos.com/kubevirt-hyperconverged created
[14-07-2025 21:22:04] INFO - Wait for Operator to be ready
error: no matching resources found
[14-07-2025 21:22:05] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/3600 sec. timeout...
error: timed out waiting for the condition on clusterserviceversions/kubevirt-hyperconverged-operator.v4.19.0
[14-07-2025 21:22:45] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 41/3600 sec. timeout...
clusterserviceversion.operators.coreos.com/kubevirt-hyperconverged-operator.v4.19.0 condition met
[14-07-2025 21:23:00] INFO - Wait for Workload to be ready
pod/aaq-operator-6fbb7d69cd-rdffh condition met
pod/aaq-operator-6fbb7d69cd-rdffh condition met
pod/cdi-operator-945765b7b-mvgqb condition met
pod/cdi-operator-945765b7b-mvgqb condition met
pod/cluster-network-addons-operator-67d7bf8dbf-zcg7b condition met
pod/cluster-network-addons-operator-67d7bf8dbf-zcg7b condition met
pod/hco-operator-5fb65f74f6-b7ghr condition met
pod/hco-operator-5fb65f74f6-b7ghr condition met
pod/hco-webhook-5d9f74f855-dvtt7 condition met
pod/hco-webhook-5d9f74f855-dvtt7 condition met
pod/hostpath-provisioner-operator-f875fb674-n5sbx condition met
pod/hostpath-provisioner-operator-f875fb674-n5sbx condition met
pod/hyperconverged-cluster-cli-download-7ffc87dffd-87szc condition met
pod/hyperconverged-cluster-cli-download-7ffc87dffd-87szc condition met
pod/ssp-operator-765ffff5fd-6z44q condition met
pod/ssp-operator-765ffff5fd-6z44q condition met
pod/virt-operator-684b76dd8-cxbwx condition met
pod/virt-operator-684b76dd8-cxbwx condition met
pod/virt-operator-684b76dd8-scrpx condition met
pod/virt-operator-684b76dd8-scrpx condition met
[14-07-2025 21:23:21] INFO - Running Kustomize build part 02...
hyperconverged.hco.kubevirt.io/kubevirt-hyperconverged created
[14-07-2025 21:23:22] INFO - Wait for HyperConverged configuration to be ready
error: timed out waiting for the condition on hyperconvergeds/kubevirt-hyperconverged
[14-07-2025 21:23:53] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 31/3600 sec. timeout...
error: timed out waiting for the condition on hyperconvergeds/kubevirt-hyperconverged
[14-07-2025 21:24:33] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 71/3600 sec. timeout...
error: timed out waiting for the condition on hyperconvergeds/kubevirt-hyperconverged
[14-07-2025 21:25:14] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 112/3600 sec. timeout...
hyperconverged.hco.kubevirt.io/kubevirt-hyperconverged condition met
hyperconverged.hco.kubevirt.io/kubevirt-hyperconverged condition met
[14-07-2025 21:25:26] INFO - Wait for Workload to be ready
pod/aaq-operator-6fbb7d69cd-rdffh condition met
pod/aaq-operator-6fbb7d69cd-rdffh condition met
pod/bridge-marker-2qxjd condition met
pod/bridge-marker-2qxjd condition met
pod/bridge-marker-4tgvf condition met
pod/bridge-marker-4tgvf condition met
pod/bridge-marker-6clfh condition met
pod/bridge-marker-6clfh condition met
pod/cdi-apiserver-6f8b75499c-tkgwb condition met
pod/cdi-apiserver-6f8b75499c-tkgwb condition met
pod/cdi-deployment-6dffc86989-q745m condition met
pod/cdi-deployment-6dffc86989-q745m condition met
pod/cdi-operator-945765b7b-mvgqb condition met
pod/cdi-operator-945765b7b-mvgqb condition met
pod/cdi-uploadproxy-5494fb6f58-g7g7w condition met
pod/cdi-uploadproxy-5494fb6f58-g7g7w condition met
pod/cluster-network-addons-operator-67d7bf8dbf-zcg7b condition met
pod/cluster-network-addons-operator-67d7bf8dbf-zcg7b condition met
pod/hco-operator-5fb65f74f6-b7ghr condition met
pod/hco-operator-5fb65f74f6-b7ghr condition met
pod/hco-webhook-5d9f74f855-dvtt7 condition met
pod/hco-webhook-5d9f74f855-dvtt7 condition met
pod/hostpath-provisioner-operator-f875fb674-n5sbx condition met
pod/hostpath-provisioner-operator-f875fb674-n5sbx condition met
pod/hyperconverged-cluster-cli-download-7ffc87dffd-87szc condition met
pod/hyperconverged-cluster-cli-download-7ffc87dffd-87szc condition met
pod/kube-cni-linux-bridge-plugin-4jlmr condition met
pod/kube-cni-linux-bridge-plugin-4jlmr condition met
pod/kube-cni-linux-bridge-plugin-fhdjd condition met
pod/kube-cni-linux-bridge-plugin-fhdjd condition met
pod/kube-cni-linux-bridge-plugin-jdvxk condition met
pod/kube-cni-linux-bridge-plugin-jdvxk condition met
pod/kubemacpool-cert-manager-547c58c8dc-lmfcc condition met
pod/kubemacpool-cert-manager-547c58c8dc-lmfcc condition met
pod/kubemacpool-mac-controller-manager-cfd4f668b-fvn8w condition met
pod/kubemacpool-mac-controller-manager-cfd4f668b-fvn8w condition met
pod/kubevirt-apiserver-proxy-f9b7fff64-w4vn8 condition met
pod/kubevirt-apiserver-proxy-f9b7fff64-w4vn8 condition met
pod/kubevirt-apiserver-proxy-f9b7fff64-xgshl condition met
pod/kubevirt-apiserver-proxy-f9b7fff64-xgshl condition met
pod/kubevirt-console-plugin-6b75855886-kl8m9 condition met
pod/kubevirt-console-plugin-6b75855886-kl8m9 condition met
pod/kubevirt-console-plugin-6b75855886-mz7x6 condition met
pod/kubevirt-console-plugin-6b75855886-mz7x6 condition met
pod/kubevirt-ipam-controller-manager-6c9bcccdbd-pcdsz condition met
pod/kubevirt-ipam-controller-manager-6c9bcccdbd-pcdsz condition met
pod/ssp-operator-765ffff5fd-6z44q condition met
pod/ssp-operator-765ffff5fd-6z44q condition met
pod/virt-api-96bcd44fc-g4tl2 condition met
pod/virt-api-96bcd44fc-g4tl2 condition met
pod/virt-api-96bcd44fc-hfwrl condition met
pod/virt-api-96bcd44fc-hfwrl condition met
pod/virt-controller-5c6f684699-f89d9 condition met
pod/virt-controller-5c6f684699-f89d9 condition met
pod/virt-controller-5c6f684699-lwp7g condition met
pod/virt-controller-5c6f684699-lwp7g condition met
pod/virt-exportproxy-97cfb96bd-n7nls condition met
pod/virt-exportproxy-97cfb96bd-n7nls condition met
pod/virt-exportproxy-97cfb96bd-ndg97 condition met
pod/virt-exportproxy-97cfb96bd-ndg97 condition met
pod/virt-handler-5jj25 condition met
pod/virt-handler-5jj25 condition met
pod/virt-handler-xlb6h condition met
pod/virt-handler-xlb6h condition met
pod/virt-handler-xpbzb condition met
pod/virt-handler-xpbzb condition met
pod/virt-operator-684b76dd8-cxbwx condition met
pod/virt-operator-684b76dd8-cxbwx condition met
pod/virt-operator-684b76dd8-scrpx condition met
pod/virt-operator-684b76dd8-scrpx condition met
pod/virt-template-validator-57d89bf8bd-cqc9c condition met
pod/virt-template-validator-57d89bf8bd-cqc9c condition met
pod/virt-template-validator-57d89bf8bd-fr6bx condition met
pod/virt-template-validator-57d89bf8bd-fr6bx condition met
[14-07-2025 21:26:39] INFO - Install OpenShift Virtualization Operator | Completed | ✅
[14-07-2025 21:26:39] INFO - Bootstrap - Install OpenShift Virtualization Operator | Completed | ✅
[14-07-2025 21:26:39] INFO - Bootstrap - Install OpenShift Serverless Operator | ⏳
[14-07-2025 21:26:39] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-serverless/setup.sh
[14-07-2025 21:26:39] INFO - Install OpenShift Serverless Operator | ⏳
[14-07-2025 21:26:39] INFO - Running Kustomize build part 01...
namespace/openshift-serverless created
operatorgroup.operators.coreos.com/openshift-serverless-operator-group created
subscription.operators.coreos.com/serverless-operator created
[14-07-2025 21:26:40] INFO - Wait for Operator to be ready
error: no matching resources found
[14-07-2025 21:26:41] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/1800 sec. timeout...
error: no matching resources found
[14-07-2025 21:26:52] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 12/1800 sec. timeout...
clusterserviceversion.operators.coreos.com/serverless-operator.v1.36.0 condition met
[14-07-2025 21:27:06] INFO - Wait for Workload to be ready
pod/knative-openshift-59b4f8885d-r6sjj condition met
pod/knative-openshift-59b4f8885d-r6sjj condition met
pod/knative-openshift-ingress-5f575cdc76-2h744 condition met
pod/knative-openshift-ingress-5f575cdc76-2h744 condition met
pod/knative-operator-webhook-787f5cc844-6c8ws condition met
pod/knative-operator-webhook-787f5cc844-6c8ws condition met
[14-07-2025 21:27:13] INFO - Running Kustomize build part 02...
knativeserving.operator.knative.dev/knative-serving created
[14-07-2025 21:27:15] INFO - Wait for KnativeServing setup to be ready
error: no matching resources found
[14-07-2025 21:27:16] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/1800 sec. timeout...
pod/activator-6fdfdcf87-64k75 condition met
pod/activator-6fdfdcf87-64k75 condition met
pod/autoscaler-cd6f877fc-b6ms9 condition met
pod/autoscaler-cd6f877fc-tptxt condition met
pod/autoscaler-cd6f877fc-b6ms9 condition met
pod/autoscaler-cd6f877fc-tptxt condition met
pod/autoscaler-hpa-59bdc86c4f-jz4d7 condition met
pod/autoscaler-hpa-59bdc86c4f-txg7t condition met
pod/autoscaler-hpa-59bdc86c4f-jz4d7 condition met
pod/autoscaler-hpa-59bdc86c4f-txg7t condition met
pod/controller-777d7844-lphwg condition met
pod/controller-777d7844-p5j2l condition met
pod/controller-777d7844-lphwg condition met
pod/controller-777d7844-p5j2l condition met
pod/webhook-785d4998c8-7xbqj condition met
pod/webhook-785d4998c8-fw8cw condition met
pod/webhook-785d4998c8-7xbqj condition met
pod/webhook-785d4998c8-fw8cw condition met
pod/3scale-kourier-gateway-7bc4cb475f-4kb7d condition met
pod/3scale-kourier-gateway-7bc4cb475f-kln6z condition met
pod/3scale-kourier-gateway-7bc4cb475f-4kb7d condition met
pod/3scale-kourier-gateway-7bc4cb475f-kln6z condition met
pod/net-kourier-controller-7b9d5c44bc-qp6vm condition met
pod/net-kourier-controller-7b9d5c44bc-tkw6m condition met
pod/net-kourier-controller-7b9d5c44bc-qp6vm condition met
pod/net-kourier-controller-7b9d5c44bc-tkw6m condition met
[14-07-2025 21:28:04] INFO - Install OpenShift Serverless Operator | Completed | ✅
[14-07-2025 21:28:04] INFO - Bootstrap - Install OpenShift Serverless Operator | Completed | ✅
[14-07-2025 21:28:04] INFO - Bootstrap - Setup the OpenShift Pipelines Operator | ⏳
[14-07-2025 21:28:04] INFO - Script | /workspaces/OpenShiftDemoTime/assets/components/openshift-pipelines/setup.sh
[14-07-2025 21:28:04] INFO - Install the OpenShift Pipelines Operator | ⏳
[14-07-2025 21:28:04] INFO - Running Kustomize build...
subscription.operators.coreos.com/openshift-pipelines-operator-rh created
[14-07-2025 21:28:05] INFO - Wait for Operator to be ready
clusterserviceversion.operators.coreos.com/serverless-operator.v1.36.0 condition met
error: the server doesn't have a resource type "tektonconfigs"
[14-07-2025 21:28:08] WARNING - Command failed | Retrying | Attempt 1, infinite retries, 10 sec. interval, 1/1800 sec. timeout...
error: the server doesn't have a resource type "tektonconfigs"
[14-07-2025 21:28:19] WARNING - Command failed | Retrying | Attempt 2, infinite retries, 10 sec. interval, 12/1800 sec. timeout...
Error from server (NotFound): tektonconfigs.operator.tekton.dev "config" not found
[14-07-2025 21:28:30] WARNING - Command failed | Retrying | Attempt 3, infinite retries, 10 sec. interval, 23/1800 sec. timeout...
config               
[14-07-2025 21:28:42] INFO - Wait for Workload to be ready
pod/openshift-pipelines-operator-8945758c7-99rpr condition met
pod/openshift-pipelines-operator-8945758c7-99rpr condition met
[14-07-2025 21:28:44] INFO - Install the OpenShift Pipelines Operator | Completed | ✅
[14-07-2025 21:28:44] INFO - Bootstrap - Setup the OpenShift Pipelines Operator | Completed | ✅
```
