# Demo 02

Source: https://redhatquickcourses.github.io/rhde-microshift/rhde-microshift/1/index.html

## Prepare workstation

```shell
sudo dnf install -y osbuild-composer composer-cli cockpit-composer qemu-kvm libvirt libvirt-nss virt-install virt-viewer cockpit-machines jq lorax container-tools && \
sudo systemctl enable osbuild-composer.socket --now && \
sudo systemctl enable cockpit.socket --now && \
sudo firewall-cmd --add-service=cockpit --permanent && \
sudo firewall-cmd --reload && \
sudo usermod -a -G weldr student && \
sudo groupmod libvirt -a -U student && \
echo 'source /etc/bash_completion.d/composer-cli' >> $HOME/.bashrc && \
sudo mkdir /etc/qemu && \
sudo bash -c 'echo "allow virbr0" > /etc/qemu/bridge.conf' && \
sudo chmod a+r /etc/qemu/bridge.conf && \
sudo systemctl enable virtnetworkd --now && \
sudo sed -i '/^hosts:/c\hosts:      files dns libvirt libvirt_guest myhostname' /etc/nsswitch.conf && \
sudo reboot

sudo mkdir -p /etc/osbuild-composer/repositories && \
sudo cp /usr/share/osbuild-composer/repositories/rhel-9.5.json /etc/osbuild-composer/repositories/
sudo curl -L -o /etc/osbuild-composer/repositories/rhel-9.5.json https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/repositories/rhel-9.5.json && \
sudo systemctl stop osbuild-worker@1.service && \
sudo systemctl restart osbuild-composer && \
ssh-keygen -R servera

```

## Prepare servera

```shell
sudo dnf -y install httpd rpm-ostree ostree container-tools && \
sudo systemctl enable httpd --now && \
sudo firewall-cmd --add-service=http --permanent && \
sudo firewall-cmd --add-port=8443/tcp --permanent && \
sudo firewall-cmd --reload && \
wget -q http://content.example.com/rhde/rhocp/mirror-registry-amd64.tar.gz && \
mkdir mirror-registry && \
tar xzvf mirror-registry-amd64.tar.gz -C mirror-registry && \
sudo ./mirror-registry/mirror-registry install -v --quayHostname servera.lab.example.com --quayRoot /var/quay --initUser microshift --initPassword redhat123 && \
sudo podman ps && \
sudo cp /var/quay/quay-rootCA/rootCA.pem /var/www/html/quay-rootCA.pem

```

## Some extra workstation stuff

```shell
wget -q http://servera.lab.example.com/quay-rootCA.pem  && \
sudo cp quay-rootCA.pem /etc/pki/ca-trust/source/anchors  && \
sudo update-ca-trust  && \
podman login -u microshift -p redhat123 https://servera.lab.example.com:8443 && \
cp $XDG_RUNTIME_DIR/containers/auth.json mirror-pull-secret && \
wget -q http://content.example.com/rhde/oci/microshift-containers.tar.gz && \
tar xzf microshift-containers.tar.gz  && \
wget -q http://content.example.com/rhde/oci/app-containers.tar.gz && \
tar xzf app-containers.tar.gz && \
wget -q https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/sh/upload-microshift.sh && \
sh upload-microshift.sh && \
wget -q https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/sh/upload-apps.sh && \
sh upload-apps.sh
```

## Install and configure microshift

```shell
sudo dnf install microshift -y

sudo cp mirror-pull-secret /etc/crio/openshift-pull-secret && \
sudo chmod 600 /etc/crio/openshift-pull-secret && \
wget -q https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/microshift/999-microshift-mirror.conf && \
sudo cp 999-microshift-mirror.conf /etc/containers/registries.conf.d/999-microshift-mirror.conf && \
wget -q https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/microshift/containers-policy.json.nosigs && \
sudo cp containers-policy.json.nosigs /etc/containers/policy.json && \
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 && \
sudo firewall-cmd --permanent --zone=trusted --add-source=169.254.169.1 && \
sudo firewall-cmd --reload && \
sudo systemctl enable microshift --now && \
sudo cp /var/lib/microshift/resources/kubeadmin/kubeconfig ~/local-admin && \
sudo chown student:student ~/local-admin && \
chmod a-w ~/local-admin && \
export KUBECONFIG=~/local-admin

oc get nodes

watch oc get pods -A

oc create deployment hello --image servera.lab.example.com:8443/flozanorht/php-ubi:9

watch oc get pods -A

```