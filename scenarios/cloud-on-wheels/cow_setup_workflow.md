# Setting up Cloud on Wheels

## Ensure hardware availability

- Rack 'n Stack.
- Bare metal machines, network switches, network router.
- Connected and powered on.
- Accessible and operational.
- According to minimal requirements to host workload on.

## Ensure network availability

- Operational network.
- Routable private network.
- Internet access.
- Machine connectivity.

## Setup the Utility machine

- Download RHEL9 DVD ISO, mount and install minimal host.
- SSH as radix into utility host.
- Become root.
- Update to latest updates.

```shell
dnf update -y
```

- Install cockpit packages:

```shell
dnf install cockpit cockpit-bridge cockpit-composer cockpit-files cockpit-machines cockpit-ostree cockpit-packagekit cockpit-pcp cockpit-podman cockpit-storaged cockpit-system cockpit-ws -y
```

- Enable cockpit and setup firewall

```shell
systemctl enable cockpit.socket --now &&\
firewall-cmd --add-service=cockpit --permanent &&\
firewall-cmd --reload
```

- Install Hypervisor

```shell
dnf install qemu-kvm libvirt-daemon-kvm virt-install virt-manager
```

- Enable libvirt

```shell
systemctl enable libvirtd --now
```

- Get into the cockpit web ui https://192.168.88.40:9090
- Enable Red Hat Insights
- Check storage and ensure sufficient storage
- Create a bridge with the active NIC port (ens1f0np0)
- Copy a RHEL9.6 DVD iso to folder "var/lib/libvirt/images"

### Setup Cockpit with custom CA on RHIDM

- Log in on Utility machine.
- Get kerberos ticket

```shell
kinit admin

klist
```

- Run this command

```shell
FQDN=$(hostname -f) && \
ipa-getcert request \
  -I "Cockpit-HTTP" \
  -N "CN=$FQDN" \
  -D "$FQDN" \
  -K "HTTP/$FQDN" \
  -f /etc/cockpit/ws-certs.d/1-ipa.cert \
  -k /etc/cockpit/ws-certs.d/1-ipa.key \
  -g cockpit-ws \
  -m 440 \
  -M 444 \
  -C "systemctl restart cockpit.socket"
```

- Verify (should be on MONITORING status)

```shell
ipa-getcert list
```

- Reload Cockpit

```shell
systemctl restart cockpit.socket
```

### Trust the CA on your machine (Mac keychain)

```shell
scp root@idm.north.star:/etc/ipa/ca.crt ~/Downloads/idm_ca.crt
```

- Double click the idm_ca.crt
- Key chain opens.
- Import and find the certificate.
- Open it.
- Set to always trust.

## Setup Red Hat Identity Management

- Create a VM to use for Red Hat IDM "idm.north.star"

```
CPU: 8
Mem: 16GB
Storage: 150GB

Enable during Host boot.
Setup default minimal RHEL9.6.
Setup Networking 192.168.88.70
Set hostname idm.north.star
Setup disk config.
```

- Create vanilla VM snapshot (powered off).
- Start machine and log in.
- Set `/etc/hosts`

```shell
192.168.88.70 idm.north.star
```

- Setup firewall

```shell
systemctl enable firewalld.service --now &&\
firewall-cmd --permanent --add-port={80/tcp,443/tcp,389/tcp,636/tcp,88/tcp,88/udp,464/tcp,464/udp,53/tcp,53/udp} &&\
firewall-cmd --permanent --add-service={freeipa-4,dns} &&\
firewall-cmd --reload
```

- Install RHIDM server.

```shell
dnf install ipa-server ipa-server-dns -y
```

```shell
ipa-server-install \
  --unattended \
  --hostname=idm.north.star \
  --domain=north.star \
  --realm=NORTH.STAR \
  --ds-password='<DIRECTORY SERVER PASSWORD>' \
  --admin-password='<IPA ADMIN PASSWORD>' \
  --ip-address=192.168.88.70 \
  --random-serial-numbers \
  --setup-dns \
  --forwarder=192.168.88.1 \
  --auto-reverse \
  --netbios-name=NORTH \
  --no-dnssec-validation
```

### Setup IPA Client

- Install IPA Client

```shell
dnf install ipa-client -y
```

- Ensure DNS is set to IDM server (DNS server) IP.

```shell
ipa-client-install \
  --unattended \
  --mkhomedir \
  --principal=admin \
  --password='<IPA ADMIN PASSWORD>' \
  --no-ntp
```

> Some resources:
> - https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/installing_identity_management/index#prerequisites
> - https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/installing_identity_management/index#installing-an-ipa-server-with-integrated-dns_installing-identity-management

## Set up DNS for OpenShift

- Set up DNS records for apps and API

```
kinit admin
klist

ipa dnszone-add ocp-hub.north.star   --name-server=idm.north.star.   --admin-email=hostmaster.north.star.
ipa dnsrecord-add ocp-hub.north.star api --a-rec=192.168.88.60
ipa dnsrecord-add ocp-hub.north.star api-int --a-rec=192.168.88.60
ipa dnsrecord-add ocp-hub.north.star '*.apps' --a-rec=192.168.88.61
ipa dnsrecord-add 88.168.192.in-addr.arpa. 60   --ptr-rec=api.ocp-hub.north.star.
ipa dnsrecord-add 88.168.192.in-addr.arpa. 61   --ptr-rec=console.apps.ocp-hub.north.star.

dig @localhost api.ocp-hub.north.star +short
dig @localhost api-int.ocp-hub.north.star +short
dig @localhost console.apps.ocp-hub.north.star +short
dig @localhost foo.apps.ocp-hub.north.star +short
dig @localhost -x 192.168.88.60 +short
dig @localhost -x 192.168.88.61 +short
```


### Trouble shoot DNS when installing or running a cluster

```
arping -c 3 192.168.88.61
arping -c 3 192.168.88.60

ip neigh | egrep '192\.168\.88\.(60|61)' || true

curl -k https://api-int.ocp-hub.north.star:6443/readyz || true &&\
curl -k https://api.ocp-hub.north.star:6443/readyz || true &&\
curl -k https://api-int.ocp-hub.north.star:6443/readyz || true

nc -vz 192.168.88.60 22623

curl -k -v --connect-timeout 3 https://192.168.88.60:22623/config/master

curl -vk --connect-timeout 3 https://192.168.88.60:22623/healthz
```

## Set up OCP cluster using Assisted installer

- Go to and create a new cluster: https://console.redhat.com/openshift/assisted-installer/clusters
- Once made it will also show up on: https://console.redhat.com/openshift/cluster-list
- Fill in all the needed details up to the point of adding hosts through the discovery ISO.
- Download the discovery ISO.
- Mount it on the Bare metals that need to be booted.
- Choose for deploying only 3 master nodes (Compact Cluster).

> Important, somehow it fails when deploying a 6 node OpenShift Cluster. Not sure why. Best rate of success was when deploying a Compact Cluster (3x master). Additionally one can add the node role to the specified machine upon initiating the installation. Adding hosts is possible once the assisted installer is finalized. This goes again through a short discovery process using a newly generated discovery ISO. Download it, mount it on the bare metals and run them. They automatically appear in the cluster yet require approval (2x times) before the node reaches it's ready state.

### Add additional worker nodes

- Go to and select the specified cluster: https://console.redhat.com/openshift/cluster-list
- Go to the tab "Add hosts".
- Click the "Add hosts" button to generate a discovery iso.
- Download it and mount it and run it.
- Hosts will automatically appear in the running OpenShift Cluster.
- Approve the nodes to join the cluster.
- Wait for ready mode.

- Disable master schedulable: https://access.redhat.com/solutions/4564851

```
oc patch scheduler cluster --type merge -p '{"spec":{"mastersSchedulable":false}}'
```

## Configure OCP Cluster for scenario use case

- Make sure to have an existing login session with the `oc` cli utility. If not, just log in on the cluster using the `oc login` command.
- Run below scripts in 3 steps/stages. It's not perfect yet it's required due to workload ans service readiness and availability.

- Stage 1
  - Setup RHACM, MultiClusterHub, GitOps and Pipelines
- Stage 2
  - Setup Local Storage Operator and OpenShift Data Foundation Operator including storage setup
  - NOTE; When done, it requires some time for the Storage System to be healthy. Have patience.
- Stage 3
  - Setup OpenShift Virtualization

```shell
[vscode@a6d1a8ba9508 OpenShiftDemoTime]$ ./scenarios/cloud-on-wheels/bootstrap-ocp-hub-stage-01.sh

[vscode@a6d1a8ba9508 OpenShiftDemoTime]$ ./scenarios/cloud-on-wheels/bootstrap-ocp-hub-stage-02.sh

[vscode@a6d1a8ba9508 OpenShiftDemoTime]$ ./scenarios/cloud-on-wheels/bootstrap-ocp-hub-stage-03.sh
```

### Setup Multicluster observability

Source: https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.14/html-single/observability/index#enabling-observability-service

- Run these commands:

```
oc create namespace open-cluster-management-observability

DOCKER_CONFIG_JSON=`oc extract secret/pull-secret -n openshift-config --to=-`

oc create secret generic multiclusterhub-operator-pull-secret \
    -n open-cluster-management-observability \
    --from-literal=.dockerconfigjson="$DOCKER_CONFIG_JSON" \
    --type=kubernetes.io/dockerconfigjson
```

- Create an object bucket claim

```yaml
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: thanos-bucket-claim
  namespace: open-cluster-management-observability
spec:
  generateBucketName: thanos
  storageClassName: openshift-storage.noobaa.io
```

- Run these commands to get bucket details

```shell
S3_ENDPOINT=$(oc get route s3 -n openshift-storage -o jsonpath='{.spec.host}')
echo "Endpoint: https://$S3_ENDPOINT"

BUCKET_NAME=$(oc get configmap thanos-bucket-claim -n open-cluster-management-observability -o jsonpath='{.data.BUCKET_NAME}')
echo "Bucket Name: $BUCKET_NAME"

ACCESS_KEY=$(oc get secret thanos-bucket-claim -n open-cluster-management-observability -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
echo "Access Key: $ACCESS_KEY"

SECRET_KEY=$(oc get secret thanos-bucket-claim -n open-cluster-management-observability -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)
echo "Secret Key: $SECRET_KEY"
```

- Create the secret

```
apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
  namespace: open-cluster-management-observability
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: <THANOS BUCKET>
      endpoint: s3-openshift-storage.apps.ocp-hub.north.star
      insecure: true
      access_key: <ACCESS KEY>
      secret_key: <SECRET KEY>
```

- Create the MultiClusterObservability

```yaml
kind: MultiClusterObservability
apiVersion: observability.open-cluster-management.io/v1beta2
metadata:
  name: observability
spec:
  observabilityAddonSpec: {}
  storageConfig:
    metricObjectStorage:
      key: thanos.yaml
      name: thanos-object-storage
```

### Set up OpenShift Oauth with RHIDM

- Go to cluster settings => configuration => Oauth
- Add Oauth config
- Oauth config

```yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
    - ldap:
        attributes:
          email:
            - mail
          id:
            - dn
          name:
            - cn
          preferredUsername:
            - uid
        bindDN: 'uid=admin,cn=users,cn=accounts,dc=north,dc=star'
        bindPassword:
          name: ldap-bind-password-m2nzd
        ca:
          name: ldap-ca-m48v4
        insecure: false
        url: 'ldaps://idm.north.star:636/cn=users,cn=accounts,dc=north,dc=star?uid?sub?(memberOf=cn=openshift-users,cn=groups,cn=accounts,dc=north,dc=star)'
      mappingMethod: claim
      name: idm-ldap
      type: LDAP
```

- Syn groups using this command:

```
oc adm groups sync --sync-config=ldap-sync.yaml --whitelist=whitelist.txt --confirm
```

> Files are located at `OpenShiftDemoTime/scenarios/cloud-on-wheels/ldapgroupsync`

### Set up readonly ClusterRole

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-readonly
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: 'true'
rules:
  - verbs:
      - get
      - list
      - watch
    apiGroups:
      - '*'
    resources:
      - '*'
  - verbs:
      - get
      - list
      - watch
    nonResourceURLs:
      - '*'
```

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: openshift-users-cluster-readonly
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: openshift-users
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-readonly
```

## Set up Gitlab machine

Source: https://docs.gitlab.com/install/package/almalinux/?tab=Community+Edition

- Create a VM to use for Gitlab "gitlab.north.star"

```
CPU: 8
Mem: 16GB
Storage: 200GB

Enable during Host boot.
Setup default minimal RHEL9.6.
Setup Networking 192.168.88.71
Set hostname idm.north.star
Setup disk config.
```

- Create vanilla VM snapshot (powered off).
- Start machine and log in.
- Ensure it's enrolled with `ipa-client`.

```
dnf install ipa-client -y

ipa-client-install --unattended --mkhomedir --principal=admin --password='<IPA ADMIN PASSWORD>' --no-ntp

curl "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh" | sudo bash

firewall-cmd --permanent --add-service={http,https,ssh}
firewall-cmd --reload

EXTERNAL_URL="https://gitlab.north.star" dnf install gitlab-ce -y

cat /etc/gitlab/initial_root_password
```

- Set LDAP config

```
gitlab_rails['ldap_enabled'] = true
gitlab_rails['prevent_ldap_sign_in'] = false

gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
  main:
    label: 'LDAP'
    host: 'idm.north.star'
    port: 389
    uid: 'uid'
    bind_dn: 'uid=admin,cn=users,cn=accounts,dc=north,dc=star'
    password: '<IPA ADMIN PASSWORD>'
    encryption: 'start_tls'
    verify_certificates: false
    smartcard_auth: false
    active_directory: false
    allow_username_or_email_login: false
    lowercase_usernames: false
    block_auto_created_users: false
    base: 'cn=accounts,dc=north,dc=star'
    user_filter: '(memberof=CN=ipausers,CN=groups,CN=accounts,DC=north,DC=star)'
    attributes:
      username: ['uid']
      email: ['mail']
      name: 'displayName'
      first_name: 'givenName'
      last_name: 'sn'
EOS
```

- Reconfigure

```shell
gitlab-ctl reconfigure
```

## Set up Workstation machine

- Create a VM to use as a workstation/bastion "workstation.north.star"

```
CPU: 8
Mem: 64GB
Storage: 200GB

Enable during Host boot.
Setup default minimal RHEL9.6.
Setup Networking 192.168.88.72
Set hostname idm.north.star
Setup disk config.
```

- Create vanilla VM snapshot (powered off).
- Start machine and log in.
- Ensure it's enrolled with `ipa-client`.

## Update OpenShift Cluster Certificates

> Sources:
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/configuring-certificates#updating-ca-bundle
https://developers.redhat.com/articles/2024/12/17/automatic-certificate-issuing-idm-and-cert-manager-operator-openshift?source=sso#use_acme_http_01_challenge_with_a_kubernetes_ingress_resource
> - https://www.redhat.com/en/blog/managing-automatic-certificate-management-environment-acme-identity-management-idm
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-operator-install
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-operator-issuer-acme
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-securing-routes
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-creating-certificate
> - https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-certificate-ingress_cert-manager-creating-certificate

- Add IDM CA cert as trusted CA.

```shell
oc create configmap custom-ca \
  --from-file=ca-bundle.crt=idm_ca.crt \
  -n openshift-config

oc patch proxy/cluster \
  --type=merge \
  --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
```

## Cert-manager for Red Hat OpenShift

- Install cert-manager for Red Hat OpenShift
- Create a ClusterIssuer

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: idm-acme
spec:
  acme:
    solvers:
      - http01:
          ingress:
            ingressClassName: openshift-default
    privateKeySecretRef:
      name: idm-acme-issuer-private-key
    server: 'https://idm.north.star/acme/directory'
```

### Example workload

- Some example test workload

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: hello-openshift
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello-openshift
    app.kubernetes.io/component: hello-openshift
    app.kubernetes.io/instance: hello-openshift
  name: hello-openshift
  namespace: hello-openshift
spec:
  selector:
    matchLabels:
      deployment: hello-openshift
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        deployment: hello-openshift
    spec:
      containers:
      - image: quay.io/openshifttest/hello-openshift:1.2.0
        imagePullPolicy: IfNotPresent
        name: hello-openshift
        ports:
        - containerPort: 8080
          protocol: TCP
        - containerPort: 8888
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hello-openshift
    app.kubernetes.io/component: hello-openshift
    app.kubernetes.io/instance: hello-openshift
  name: hello-openshift
  namespace: hello-openshift
spec:
  ports:
  - name: 8080-tcp
    port: 8080
    protocol: TCP
    targetPort: 8080
  - name: 8888-tcp
    port: 8888
    protocol: TCP
    targetPort: 8888
  selector:
    deployment: hello-openshift
  sessionAffinity: None
  type: ClusterIP
```

- Create a certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-route-cert
  namespace: hello-openshift
spec:
  commonName: hello-openshift.apps.ocp-hub.north.star
  dnsNames:
    - hello-openshift.apps.ocp-hub.north.star
  usages:
    - server auth
  issuerRef:
    kind: ClusterIssuer
    name: idm-acme
  secretName: example-route-cert
```

- Create a role so the router service account can read certificate / secrets.

```shell
oc create role secret-reader \
  --verb=get,list,watch \
  --resource=secrets \
  --resource-name=example-route-cert \
  --namespace=hello-openshift

oc create rolebinding secret-reader-binding \
  --role=secret-reader \
  --serviceaccount=openshift-ingress:router \
  --namespace=hello-openshift
```

- Create the route for the example application

```
oc create route edge hello-openshift \
  --service=hello-openshift \
  --hostname=hello-openshift.apps.ocp-hub.north.star \
  --namespace=hello-openshift

oc patch route hello-openshift \
  -n hello-openshift \
  --type=merge \
  -p '{"spec":{"tls":{"externalCertificate":{"name":"example-route-cert"}}}}'
```

### Certificate for API

> !!! Work in progress, does not yet have desired outcome

Source: https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-certificate-ingress_cert-manager-creating-certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: idm-api-cert
  namespace: openshift-config
spec:
  commonName: api.ocp-hub.north.star
  dnsNames:
  - api.ocp-hub.north.star
  usages:
    - server auth
  issuerRef:
    kind: ClusterIssuer
    name: idm-acme
  secretName: idm-api-cert
```

Next: https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/configuring-certificates#customize-certificates-api-add-named_api-server-certificates

### Certificate for *.apps

> !!! Work in progress, does not yet have desired outcome

Source: https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift#cert-manager-certificate-ingress_cert-manager-creating-certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: idm-apps-cert
  namespace: openshift-ingress
spec:
  commonName: "apps.ocp-hub.north.star"
  dnsNames:
  - "apps.ocp-hub.north.star"
  - "*.apps.ocp-hub.north.star"
  issuerRef:
    kind: ClusterIssuer
    name: idm-acme
  secretName: idm-apps-cert
```

