# Create and boot the RHEL for Edge Installer image for Edge devices

## Workstation

Source: https://role.rhu.redhat.com/rol-rhu/app/courses/hol007-9.2/pages/ch01s02

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

### Create a blueprint for a RHEL for Edge image

```shell
cat > rhel9-edge.toml <<'EOF'
name = "rhel9-edge"
description = "blueprint-rhel9-edge"
version = "0.0.1"
modules = [ ]
groups = [ ]

[customizations]
hostname = "edge"
EOF

composer-cli blueprints push rhel9-edge.toml
composer-cli blueprints depsolve rhel9-edge
```

### Create a rpm-ostree based RHEL image

```shell
ARCH=$(uname -i)
composer-cli compose start-ostree rhel9-edge --ref rhel/9/$ARCH/edge  edge-container

ID=$(composer-cli compose list | grep "RUNNING" | awk '{print $1}')
watch -n 10 composer-cli compose list
# Wait for it to finish

composer-cli compose image $ID
```

### Load the downloaded RHEL for Edge Container OSTree commit into Podman

```shell
sudo podman load -i $ID-container.tar

IMAGE_ID=$(sudo podman images | awk '/<none>/{print $3}')
sudo podman tag $IMAGE_ID localhost/rhel9-edge
sudo podman run -d --name=edge-container -p 8080:8080 localhost/rhel9-edge
sudo podman ps -a
```

### Create the RHEL for Edge Installer image by using the CLI

```shell
cat <<EOF > rhel9-edge-installer.toml
name = "rhel9-edge-installer"
description = "Edge Installer blueprint"
version = "0.0.1"
EOF

composer-cli blueprints push rhel9-edge-installer.toml
composer-cli blueprints depsolve rhel9-edge-installer

composer-cli compose start-ostree rhel9-edge-installer edge-installer --ref rhel/9/$ARCH/edge --url http://localhost:8080/repo/

ID=$(composer-cli compose list | grep "RUNNING" | awk '{print $1}')
watch -n 10 composer-cli compose list
# Wait for it to finish

composer-cli compose image $ID
```

### Create a kickstart file and a health check script.

```shell
cat << EOF > kickstart-edge.ks
lang en_US.UTF-8
keyboard us
timezone Etc/UTC --utc
text
zerombr
clearpart --all --initlabel
autopart --type=plain
rootpw --lock
reboot
user --name=core --group=wheel
sshkey --username=core "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGtUW3ismHyuCW4CDdTVOOOq6aySdtYenXFWWx7HJa4VTepkG00aaLId9ocra10hc+MB0GTJMCyabDv3i8NKdi6GDH/aOLVsp/Ewy8DEzZMBlJDCt4v2i4/wU4liw6KgEFkZs+5hnqU8d4QzldyGJ5onr+AGvFOKG68CS0BBl40Z1twf1HhCyx8k6nzD2ovlkxWRFZKPAFrtPCBVvQDkOfVFZF+lwzaSztgAjbFZ4A9jqQyUYx4kOJ5DtRef36ucdUdVQale0+8lICl7/gb142SPpYfhxe88/BJScLPRjvVNeu1TxRmoHtVazqnAoRxQYAn2MoI6AG+w6QuZf8f7aL LabGradingKey"

# Configure network to use DHCP and activate on boot
network --bootproto=dhcp --device=link --activate --onboot=on

# Configure ostree
ostreesetup --nogpg --osname=rhel --remote=edge --url=http://172.25.250.9:8080/repo/ --ref=rhel/9/x86_64/edge

%post --log=/var/log/anaconda/post-install.log --erroronfail

# Create a default student user, allowing it to run sudo commands without password
useradd -m -d /home/student -p $(openssl passwd -6 student | sed 's/\$/\\$/g') -G wheel student
echo -e 'student\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers

# Make sure student user directory contents ownership is correct
chown -R student:student /home/student/

# Copy the bash script which make sures configured DNS is available
curl http://172.25.250.9:8080/check-dns.sh -o /etc/greenboot/check/required.d/check-dns.sh
chmod a+x /etc/greenboot/check/required.d/check-dns.sh
%end
EOF


cat > /home/student/check-dns.sh <<'EOF'
#!/bin/bash
sleep 5
DNS_SERVER=$(grep nameserver /etc/resolv.conf | cut -f2 -d" ")

# check DNS server is available
for i in $DNS_SERVER
do
   ping -c3 $i &> /dev/null
   if [[ $? -ne 0 ]]
   then
       echo FAIL
       exit 1
   else
       echo SUCCESS
   fi
done
exit 0
EOF
```

### Copy the kickstart file and the health check script from workstation VM to the container

```shell
CID=$(sudo podman ps -a | grep -i edge-container | awk '{print $1}')

sudo podman ps -a --no-trunc

sudo podman exec -it $CID /bin/sh
cat /etc/nginx.conf

# Exit out the container

sudo podman cp kickstart-edge.ks edge-container:/usr/share/nginx/html/
sudo podman cp check-dns.sh edge-container:/usr/share/nginx/html/

sudo podman exec -it $CID /bin/sh
ls /usr/share/nginx/html/kickstart-edge.ks

# Exit out the container
```

### Provision the Edge device (VM) using RHEL for Edge image installer image (.iso) with kickstart-edge.ks as a kickstart file

```shell
curl -I http://172.25.250.9:8080/kickstart-edge.ks

sudo cp $ID-installer.iso /tmp/rhel9-edge-installer-$ARCH.iso
sudo chown qemu:qemu /tmp/rhel9-edge-installer-$ARCH.iso
sudo systemctl status libvirtd
sudo systemctl start libvirtd

sudo virt-install --name edge-rhel9 --connect qemu:///system --memory 4096  --vcpus 4  --disk size=40 --os-variant rhel9.2 --location /tmp/rhel9-edge-installer-$ARCH.iso --graphics=none --extra-args inst.ks=http://172.25.250.9:8080/kickstart-edge.ks  --extra-arg console=ttyS0 -v

# Log in,  student:student

rpm-ostree status

```