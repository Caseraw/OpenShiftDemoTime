# Create RHDE Image with Microshift and RHEL for Edge Image

This still needs some attention, it does noet all work properly.

## Workstation

Source: https://role.rhu.redhat.com/rol-rhu/app/courses/hol010-4/pages/ch01s02

### Install the RHEL Image Builder

```shell
sudo dnf repolist
sudo dnf install -y osbuild-composer composer-cli cockpit-composer bash-completion

sudo usermod -a -G weldr student
sudo dnf update
sudo reboot

sudo firewall-cmd --add-service=cockpit && sudo firewall-cmd --add-service=cockpit --permanent
sudo systemctl enable osbuild-composer.socket cockpit.socket --now
source /etc/bash_completion.d/composer-cli
```

### Override a system repository

```shell
sudo mkdir -p /etc/osbuild-composer/repositories
sudo cp /usr/share/osbuild-composer/repositories/rhel-92.json /etc/osbuild-composer/repositories/

sudo jq '.x86_64[] |= if .name == "appstream" then .baseurl = "http://content.example.com/rhel9.2/x86_64/dvd/AppStream" | .rhsm = false | .check_gpg = false elif .name == "baseos" then .baseurl = "http://content.example.com/rhel9.2/x86_64/dvd/BaseOS" | .rhsm = false | .check_gpg = false else . end' /etc/osbuild-composer/repositories/rhel-92.json > /tmp/rhel-92.json


sudo cp /tmp/rhel-92.json /etc/osbuild-composer/repositories/rhel-92.json

sudo systemctl restart osbuild-composer.service
```

### Add the MicroShift repositories to Image Builder

```shell
ARCH=$(uname -i)

cat > rhocp-source.toml <<'EOF'
id = "rhocp-4.14"
name = "Red Hat OpenShift Container Platform 4.14 for RHEL 9"
type = "yum-baseurl"
url = "http://content.example.com/rhel9.2/$ARCH/rhel9-additional/rhocp-4.14-for-rhel-9-x86_64-rpms/"
check_gpg = false
check_ssl = false
system = false
rhsm = false
EOF

cat > fdp-source.toml <<'EOF'
id = "fast-datapath"
name = "Fast Datapath for RHEL 9"
type = "yum-baseurl"
url = "http://content.example.com/rhel9.2/$ARCH/rhel9-additional/fast-datapath-for-rhel-9-x86_64-rpms/"
check_gpg = false
check_ssl = false
system = false
rhsm = false
EOF

sudo composer-cli sources add rhocp-source.toml
sudo composer-cli sources add fdp-source.toml

sudo composer-cli sources list

cat << EOF > microshift-container.toml
name = "microshift-container"

description = "RHEL for Edge image with MicroShift"
version = "0.0.1"
modules = []
groups = []

# MicroShift and dependencies

[[packages]]
name = "microshift"
version = ""

[[packages]]
name = "openshift-clients"
version = ""

[customizations]
hostname = "rhde"

[customizations.services]
enabled = ["microshift"]
EOF

sudo composer-cli blueprints push microshift-container.toml
sudo composer-cli blueprints depsolve microshift-container
```

### Create a rpm-ostree based RHEL image

```shell
sudo composer-cli compose start-ostree microshift-container --ref rhel/9/$ARCH/edge  edge-container

ID=$(sudo composer-cli compose list | grep "RUNNING" | awk '{print $1}')

watch -n 10 sudo composer-cli compose list
# Wait to finish

sudo composer-cli compose image $ID

sudo podman load -i $ID-container.tar

IMAGE_ID=$(sudo podman images | awk '/<none>/{print $3}')

sudo podman tag $IMAGE_ID localhost/microshift-container

sudo podman run -d --name=edge-container -p 8080:8080 localhost/microshift-container
```

### Create the RHEL for Edge Installer image by using the CLI

```shell
cat <<EOF > microshift-installer.toml
name = "microshift-installer"
description = "MicroShift Installer blueprint"
version = "0.0.1"
EOF

sudo composer-cli blueprints push microshift-installer.toml
sudo composer-cli blueprints depsolve microshift-installer

sudo composer-cli compose start-ostree microshift-installer edge-installer --ref rhel/9/$ARCH/edge --url http://localhost:8080/repo/

ID=$(sudo composer-cli compose list | grep "RUNNING" | awk '{print $1}')
watch -n 10 composer-cli compose list
# Wait for it to finish

sudo composer-cli compose image $ID
```

### Create a kickstart file

```shell
cat << EOF > kickstart-microshift.ks
lang en_US.UTF-8
keyboard us
timezone Etc/UTC --utc
text
reboot
user --name=core --group=wheel
sshkey --username=core "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGtUW3ismHyuCW4CDdTVOOOq6aySdtYenXFWWx7HJa4VTepkG00aaLId9ocra10hc+MB0GTJMCyabDv3i8NKdi6GDH/aOLVsp/Ewy8DEzZMBlJDCt4v2i4/wU4liw6KgEFkZs+5hnqU8d4QzldyGJ5onr+AGvFOKG68CS0BBl40Z1twf1HhCyx8k6nzD2ovlkxWRFZKPAFrtPCBVvQDkOfVFZF+lwzaSztgAjbFZ4A9jqQyUYx4kOJ5DtRef36ucdUdVQale0+8lICl7/gb142SPpYfhxe88/BJScLPRjvVNeu1TxRmoHtVazqnAoRxQYAn2MoI6AG+w6QuZf8f7aL LabGradingKey"

# Configure network to use DHCP and activate on boot
network --bootproto=dhcp --device=link --activate --onboot=on

zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=200
part /boot --fstype=xfs --asprimary --size=800
part pv.01 --grow
volgroup rhel pv.01
logvol / --vgname=rhel --fstype=xfs --size=10240 --name=root

# Configure ostree
ostreesetup --nogpg --osname=rhel --remote=edge --url=http://172.25.250.9:8080/repo/ --ref=rhel/9/$ARCH/edge

%post --log=/var/log/anaconda/post-install.log --erroronfail

# The pull secret is mandatory for MicroShift builds on top of OpenShift, but not OKD
# The /etc/crio/crio.conf.d/microshift.conf references the /etc/crio/openshift-pull-secret file
cat > /etc/crio/openshift-pull-secret << EOFPS
REPLACE_OCP_PULL_SECRET_CONTENTS
EOFPS
chmod 600 /etc/crio/openshift-pull-secret
# Create a default student user, allowing it to run sudo commands without password
useradd -m -d /home/student -p $(openssl passwd -6 student | sed 's/\$/\\$/g') -G wheel student
echo -e 'student\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers
# Make sure student user directory contents ownership is correct
chown -R student:student /home/student/
# Configure the firewall (rules reload is not necessary here)
firewall-offline-cmd --zone=trusted --add-source=10.42.0.0/16
firewall-offline-cmd --zone=trusted --add-source=169.254.169.1
# Make the KUBECONFIG from MicroShift directly available for the root user
echo -e 'export KUBECONFIG=/var/lib/microshift/resources/kubeadmin/kubeconfig' >> /root/.profile

%end
EOF

PULL_SECRET='<copy paste pull secret here>'

sed -i "s/REPLACE_OCP_PULL_SECRET_CONTENTS/$PULL_SECRET/g" kickstart-microshift.ks
```

### Copy the kickstart file from workstation VM to container

```shell
CID=$(sudo podman ps -a | grep -i edge-container | awk '{print $1}')

sudo podman ps -a --no-trunc

sudo podman cp kickstart-microshift.ks edge-container:/usr/share/nginx/html/
```

### Provision the Edge device (VM) using Microshift embedded RHEL for Edge image installer image (.iso) with kickstart-microshift.ks as a kickstart file.

```shell
curl -I http://172.25.250.9:8080/kickstart-microshift.ks

sudo cp $ID-installer.iso /tmp/redhat-device-edge-installer-$ARCH.iso

sudo chown qemu:qemu /tmp/redhat-device-edge-installer-$ARCH.iso

sudo systemctl status libvirtd

sudo systemctl start libvirtd

sudo virt-install --name rhde-rhel9 --connect qemu:///system --memory 4096  --vcpus 4  --disk size=40 --os-variant rhel9.2 --location /tmp/redhat-device-edge-installer-$ARCH.iso --graphics=none --extra-args inst.ks=http://172.25.250.9:8080/kickstart-microshift.ks  --extra-arg console=ttyS0 -v

# login student:student

mkdir ~/.kube

sudo cat /var/lib/microshift/resources/kubeadmin/kubeconfig > ~/.kube/config

oc get pods -A

oc get nodes

microshift version
```