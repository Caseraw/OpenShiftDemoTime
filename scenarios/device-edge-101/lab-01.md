# Lab: Install Image Builder on a Development Machine

Source: https://redhatquickcourses.github.io/rhde-build/rhde-build/1/ch1-build/s4-install-lab.html

## Workstation

### Lab: Install Image Builder on a Development Machine

@demo

```shell
sudo dnf install -y osbuild-composer composer-cli cockpit-composer qemu-kvm libvirt virt-install virt-viewer cockpit-machines jq lorax && \
sudo systemctl enable osbuild-composer.socket --now && \
sudo systemctl enable cockpit.socket --now && \
sudo firewall-cmd --add-service=cockpit --permanent && \
sudo firewall-cmd --reload && \
sudo usermod -a -G weldr student && \
sudo groupmod libvirt -a -U student && \
echo 'source /etc/bash_completion.d/composer-cli' >> $HOME/.bashrc && \
sudo reboot

# composer-cli compose types

# Check cocpit
# https://127.0.0.1:9090/composer

sudo mkdir -p /etc/osbuild-composer/repositories && \
sudo cp /usr/share/osbuild-composer/repositories/rhel-9.5.json /etc/osbuild-composer/repositories/
sudo curl -L -o /etc/osbuild-composer/repositories/rhel-9.5.json https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/repositories/rhel-9.5.json && \
sudo systemctl stop osbuild-worker@1.service && \
sudo systemctl restart osbuild-composer

# composer-cli sources list && \
# composer-cli sources info baseos && \
# composer-cli sources info appstream

# rpm-ostree --version && \
# ostree --version
```

### Lab: Create and Manage Blueprints for Edge Images

```shell
composer-cli status show && \
curl -L -o rhel9-edge.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-edge.toml && \
composer-cli blueprints push rhel9-edge.toml && \
composer-cli blueprints list && \
composer-cli blueprints show rhel9-edge && \
composer-cli blueprints depsolve rhel9-edge

curl -L -o rhel9-httpd.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-httpd.toml && \
composer-cli blueprints depsolve rhel9-edge | grep httpd && \
composer-cli blueprints push rhel9-httpd.toml && \
composer-cli blueprints depsolve rhel9-edge | grep httpd
```

### Lab: Create and Manage Composes for Edge Images

```shell
composer-cli status show && \
composer-cli blueprints show rhel9-edge

composer-cli compose start-ostree rhel9-edge edge-commit && \
composer-cli compose list

# Wait for image build to finish

composer-cli compose image <image UUID>

```

### Lab: Create a Remote OSTree Repository

```shell

# Webserver servera
ssh servera

sudo dnf -y install httpd rpm-ostree ostree && \
sudo systemctl enable httpd --now && \
sudo firewall-cmd --add-service=http --permanent && \
sudo firewall-cmd --reload

# Development machine

curl http://servera.lab.example.com

scp $UUID-commit.tar servera.lab.example.com:~

# Webserver servera

sudo tar xf ~/$UUID-commit.tar -C /var/www/html

ls -lZ /var/www/html && \
sudo chmod -R a+X /var/www/html && \
sudo restorecon -R /var/www/html && \
sudo rm /var/www/html/compose.json

# Development machines

curl http://servera.lab.example.com/repo/config
```

### Lab: Publish Edge Images on Remote OSTree Repositories

```shell

composer-cli status show && \
curl http://servera.lab.example.com/repo/config && \
curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/edge

curl -L -o rhel9-mysql.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-mysql.toml && \
composer-cli blueprints push rhel9-mysql.toml && \
composer-cli blueprints list && \
composer-cli compose start-ostree rhel9-mysql edge-commit --ref rhel/9/x86_64/db && \
composer-cli compose list

composer-cli compose image <image uuid>

scp $UUID-commit.tar servera.lab.example.com:~

# Webserver servera

mkdir delete-me

tar xf ~/$UUID-commit.tar -C delete-me

ostree --repo=delete-me/repo refs && \
ostree --repo=/var/www/html/repo refs && \
sudo ostree pull-local --repo=/var/www/html/repo delete-me/repo && \
ostree refs --repo=/var/www/html/repo && \
rm -rf delete-me

# Development machine

curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/db
```

### Lab: Boot Test VMs from Remote OSTree Repositories

```shell
composer-cli status show && \
curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/edge

sudo dnf install -y qemu-kvm libvirt virt-install virt-viewer cockpit-machines && \
sudo groupmod libvirt -a -U student

sudo reboot

virsh uri && \
virsh nodeinfo

curl -L -o rhel9-httpd.ks https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/ks/rhel9-httpd.ks

scp rhel9-httpd.ks servera.lab.example.com:~

# Webserver servera

sudo cp rhel9-httpd.ks /var/www/html && \
ls -lZ /var/www/html && \
sudo chmod -R a+X /var/www/html && \
sudo restorecon -R /var/www/html

# Development machines

curl http://servera.lab.example.com/rhel9-httpd.ks

wget -q http://content.example.com/rhde/isos/rhel-9.5-x86_64-boot.iso

virt-install --name edge-test-1 --os-variant rhel9.5 \
--memory 2048 --vcpus 2 --disk size=10 --graphics=none \
--location rhel-9.5-x86_64-boot.iso \
--extra-arg inst.ks=http://servera.lab.example.com/rhel9-httpd.ks \
--extra-arg console=ttyS0 -v

# core:redhat123

rpm-ostree status && \
ostree refs && \
ostree log rhel/9/x86_64/edge && \
ostree remote list --show-urls && \
ostree refs --repo=/sysroot/ostree/repo && \
df -h | grep vda && \
systemctl is-active httpd && \
curl 127.0.0.1

exit
CTRL+]
```

### Lab: Boot Test VMs from Edge Installer Images

```shell
composer-cli status show && \
curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/db && \
virsh list --all


curl -l -o mysql-installer.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/mysql-installer.toml && \
composer-cli blueprints push mysql-installer.toml && \
composer-cli blueprints list && \
composer-cli compose start-ostree mysql-installer edge-installer --ref rhel/9/x86_64/db --url http://servera.lab.example.com/repo/

composer-cli blueprints list

composer-cli compose image <uuid>

mkdir temp-iso
sudo mount -o loop,ro $UUID-installer.iso temp-iso

ls temp-iso/ && \
ls temp-iso/ostree/repo/ && \
cat temp-iso/osbuild.ks && \
sudo umount temp-iso

sudo dnf install -y lorax

iso-info $UUID-installer.iso

LABEL=RHEL-9-5-0-BaseOS-x86_64

curl -l -o rhel9-mysql-installer.ks https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/ks/rhel9-mysql-installer.ks

mkksiso --ks rhel9-mysql-installer.ks $UUID-installer.iso new-installer.iso

virt-install --name edge-db-1 --os-variant rhel9.5 --memory 4096 --vcpus 2 --disk size=20 \
--location new-installer.iso --graphics=none --extra-arg console=ttyS0 \
--extra-arg inst.ks=hd:LABEL=$LABEL:/rhel9-mysql-installer.ks -v

# core:redhat123

rpm-ostree status && \
ostree remote list --show-urls && \
systemctl is-active mysqld && \
sudo mysqlshow

exit
CTRL+]
```

### Lab: Create And Publish Edge Image Updates

```shell
composer-cli status show && \
curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/edge && \
virsh list --all

curl -l -o rhel9-httpd-v2.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-httpd-v2.toml && \
composer-cli blueprints push rhel9-httpd-v2.toml && \
composer-cli blueprints list && \
composer-cli blueprints show rhel9-edge && \
composer-cli compose start-ostree rhel9-edge edge-commit --url http://servera.lab.example.com/repo --ref rhel/9/x86_64/edge

composer-cli compose list running

UUID=<INSERT ID>

# Wait for build

composer-cli compose image $UUID --filename rhel9-httpd-v2-commit.tar && \
scp rhel9-httpd-v2-commit.tar servera:~

# Webserver servera

ls rhel9-httpd-v2-commit.tar && \
mkdir delete-me && \
tar xf rhel9-httpd-v2-commit.tar -C delete-me/ && \
ostree refs --repo=delete-me/repo && \
ostree refs --repo=/var/www/html/repo && \
ostree log rhel/9/x86_64/edge --repo=delete-me/repo && \
ostree log rhel/9/x86_64/edge --repo=/var/www/html/repo && \
sudo ostree pull-local --repo=/var/www/html/repo delete-me/repo && \
sudo ostree summary -u --repo=/var/www/html/repo && \
ostree log rhel/9/x86_64/edge --repo=/var/www/html/repo && \
rm -rf delete-me

# Webdevelopment machine

virsh console edge-test-1

sudo hostnamectl set-hostname microweb && \
cat /etc/hostname

sudo -i
cat << 'EOF' > /var/www/html/index.html
<html>
<body>
	<h1>This is an Edge Web Server</h1>
</body>
</html>
EOF
exit

curl http://127.0.0.1 && \
rpm-ostree status && \
rpm -q cockpit && \
ostree remote list --show-urls && \
sudo rpm-ostree upgrade --check && \
sudo rpm-ostree upgrade && \
rpm-ostree status

sudo systemctl reboot

rpm-ostree status && \
ostree log rhel/9/x86_64/edge && \
rpm -q cockpit && \
curl http://127.0.0.1

exit
CTRL+]
```

### Lab: Rollback Edge Image Updates

```shell
composer-cli status show && \
curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/edge && \
virsh list --all

curl -L -o rhel9-httpd-v3.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-httpd-v3.toml && \
composer-cli blueprints push rhel9-httpd-v3.toml && \
composer-cli blueprints list && \
composer-cli blueprints show rhel9-edge && \
composer-cli compose start-ostree rhel9-edge edge-commit --url http://servera.lab.example.com/repo --ref rhel/9/x86_64/edge

composer-cli compose list running

UUID=

composer-cli compose image $UUID --filename rhel9-httpd-v3-commit.tar && \
scp rhel9-httpd-v3-commit.tar servera:~

# Webserver servera

ls rhel9-httpd-v3-commit.tar && \
mkdir delete-me && \
tar xf rhel9-httpd-v3-commit.tar -C delete-me/ && \
ostree log rhel/9/x86_64/edge --repo=delete-me/repo && \
ostree log rhel/9/x86_64/edge --repo=/var/www/html/repo && \
sudo ostree pull-local --repo=/var/www/html/repo delete-me/repo && \
sudo ostree summary -u --repo=/var/www/html/repo && \
rm -rf delete-me

ostree log rhel/9/x86_64/edge --repo=/var/www/html/repo

# Development machine

virsh console edge-test-1

rpm-ostree status && \
rpm -q php

sudo rpm-ostree upgrade --check && \
sudo rpm-ostree upgrade && \
sudo systemctl reboot

rpm-ostree status && \
rpm -q php && \
date && \
sudo timedatectl set-timezone America/Aruba && \
date

sudo -i
cat << 'EOF' > /var/www/html/info.php
<html>
<body>
This is PHP version: <?= phpversion() ?>
</body>
</html>
EOF
exit

curl http://127.0.0.1/info.php

sudo rpm-ostree rollback && \
rpm-ostree status && \
sudo systemctl reboot

rpm-ostree status && \
rpm -q php && \
rpm -q cockpit && \
curl http://127.0.0.1/info.php && \
date && \
timedatectl show -p Timezone

exit
CTRL+]

```

### Lab: Update Edge Devices Using Static Deltas

```shell
composer-cli status show && \
curl http://servera.lab.example.com/repo/refs/heads/rhel/9/x86_64/db && \
virsh list --all

curl -L -o rhel9-mysql-v2.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-mysql-v2.toml && \
composer-cli blueprints push rhel9-mysql-v2.toml && \
composer-cli blueprints list && \
composer-cli blueprints show rhel9-mysql && \
composer-cli compose start-ostree rhel9-mysql edge-commit --url http://servera.lab.example.com/repo --ref rhel/9/x86_64/db

composer-cli compose list running

UUID=

composer-cli compose image $UUID --filename rhel9-mysql-v2-commit.tar && \
scp rhel9-mysql-v2-commit.tar servera:~

# Webserver servera

mkdir delete-me && \
tar xf rhel9-mysql-v2-commit.tar -C delete-me/ && \
ostree refs --repo=delete-me/repo && \
ostree refs --repo=/var/www/html/repo && \
ostree log rhel/9/x86_64/db --repo=delete-me/repo && \
ostree log rhel/9/x86_64/db --repo=/var/www/html/repo && \
sudo ostree pull-local --repo=/var/www/html/repo delete-me/repo && \
sudo ostree summary -u --repo=/var/www/html/repo && \
rm -rf delete-me

ostree log rhel/9/x86_64/db --repo=/var/www/html/repo && \
ostree static-delta list --repo /var/www/html/repo && \
sudo ostree static-delta generate rhel/9/x86_64/db --repo /var/www/html/repo && \
sudo ostree summary -u --repo /var/www/html/repo && \
ostree static-delta list --repo /var/www/html/repo

# Development machine

virsh console edge-db-1

rpm-ostree status && \
rpm -q mysql && \
ostree remote list --show-urls && \
sudo ostree remote delete db && \
sudo ostree remote add --no-gpg-verify db http://servera.lab.example.com/repo && \
ostree remote list --show-urls

sudo rpm-ostree upgrade --check && \
sudo rpm-ostree upgrade && \
sudo systemctl reboot

rpm-ostree status && \
rpm -q nano && \
sudo journalctl --no-pager -t rpm-ostree -g pull

# Webserver servera

sudo tail /var/log/httpd/access_log
```
