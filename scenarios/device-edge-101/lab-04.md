# Lab: Create RHEL for Edge Images with MicroShift

Source: https://redhatquickcourses.github.io/rhde-bootc-build/rhde-bootc-build/1/ch1-intro/s3-prereqs-lab.html

## Workstation

### Lab: Prepare to Build and Deploy Bootc Container Images

```shell
dnf repolist
dnf repoinfo rhel-10.0-for-x86_64-baseos-rpms | grep baseurl
dnf info bootc

sudo dnf install -y skopeo buildah

podman login -u student -p redhat registry.lab.example.com:5000
podman search registry.lab.example.com:5000/

# skopeo inspect --format '{{ .Labels }}' docker://registry.lab.example.com:5000/rhel10/rhel-bootc
# skopeo inspect --format '{{ json .Labels }}' docker://registry.lab.example.com:5000/rhel10/rhel-bootc | jq
# skopeo inspect --format '{{ index .Labels "containers.bootc" }}' docker://registry.lab.example.com:5000/rhel10/rhel-bootc
# skopeo inspect --format '{{ index .Labels "containers.bootc" }}' docker://registry.lab.example.com:5000/ubi10/ubi

# podman run --rm --name bootc registry.lab.example.com:5000/rhel10/rhel-bootc bash -c "rpm -q bootc"
# podman run --rm --name ubi registry.lab.example.com:5000/ubi10/ubi bash -c "rpm -q bootc"

# podman run --rm --name bootc registry.lab.example.com:5000/rhel10/rhel-bootc bash -c "rpm -q kernel"
# podman run --rm --name ubi registry.lab.example.com:5000/ubi10/ubi bash -c "rpm -q kernel"

sudo dnf install -y qemu-kvm libvirt virt-install virt-viewer
sudo systemctl enable virtqemud.socket --now
virsh uri
```

### Lab: Build and Test Bootc Containers

```shell
git clone https://github.com/RedHatQuickCourses/rhde-bootc-samples.git
cd rhde-bootc-samples
podman login -u student -p redhat registry.lab.example.com:5000

cd httpd-bootc

podman build -t httpd-bootc .
podman run -d -p 8080:80 --name httpd httpd-bootc

curl 127.0.0.1:8080

# skopeo inspect --format '{{ index .Labels "containers.bootc" }}' containers-storage:localhost/httpd-bootc

# podman exec -it httpd bash
# bash-5.2# ps ax | wc -l
# bash-5.2# exit

podman stop httpd
podman rm httpd

cd ../httpd-ubi
podman build -t httpd-ubi .
podman run -d -p 8080:80 --name httpd httpd-ubi
curl 127.0.0.1:8080

# podman exec -it httpd bash
# [root@965ed65344f0 /]# ps ax | wc -l
# [root@965ed65344f0 /]# pstree
# [root@965ed65344f0 /]# exit

podman stop httpd
podman rm httpd

cd ../webapp-bootc
podman build -t webapp-bootc .
podman run -d -p 8080:80 --name webapp webapp-bootc
curl 127.0.0.1:8080
podman stop webapp
podman rm webapp
```

### Lab: System Configuration from Containers

```shell
cd
git clone https://github.com/RedHatQuickCourses/rhde-bootc-samples.git
cd rhde-bootc-samples
podman login -u student -p redhat registry.lab.example.com:5000

cd httpd-system

podman build -t httpd-system .
podman run -d -p 8080:80 --name httpd httpd-system
curl 127.0.0.1:8080

# podman exec -it httpd bash
# bash-5.2# cat /usr/lib/sysctl.d/90-*
# bash-5.2# cat /usr/lib/bootc/kargs.d/*
# bash-5.2# ls -l /etc/systemd/system/multi-user.target.wants/httpd.service
# bash-5.2# ls -l /etc/systemd/system/multi-user.target.wants/firewalld.service
# bash-5.2# cat /etc/firewalld/zones/public.xml
# bash-5.2# cat /proc/cmdline
# bash-5.2# sysctl kernel.sysrq
# bash-5.2# firewall-cmd --list-services
# bash-5.2# systemctl is-active httpd
# bash-5.2# systemctl is-active firewalld
# bash-5.2# exit
# cat /proc/cmdline
# sysctl net.ipv4.ip_forward
# sysctl kernel.sysrq
# systemctl is-active firewalld
# firewall-cmd --list-services

podman stop httpd
podman rm httpd
```


### Lab: Test Bootc Containers With Anaconda

```shell
cd
git clone https://github.com/RedHatQuickCourses/rhde-bootc-samples.git
podman login -u student -p redhat registry.lab.example.com:5000
podman image list | grep httpd-bootc
virsh list --all

cd
mkdir temp-bootc
skopeo copy containers-storage:localhost/httpd-bootc oci:temp-bootc/oci:httpd-bootc

mkdir temp-test-vm
cp rhde-bootc-samples/ks/inst.ks temp-test-vm
cp rhde-bootc-samples/ks/virt-install.sh temp-test-vm
cd temp-test-vm
ssh-keygen -N '' -f edge-key -C 'initial key for edge devices'
SSH_PUB_KEY=$( cat edge-key.pub )
sed -i "s|REPLACE_WTH_SSH_PUB_KEY|$SSH_PUB_KEY|" inst.ks

bash virt-install.sh

# Ctrl+] to exit
ssh -i edge-key -p 8022 core@127.0.0.1

# #redhat123
# sudo bootc status
# rpm -q httpd
# systemctl is-active httpd
# cat /var/www/html/index.html
# ps ax | wc -l
# podman run quay.io/podman/hello
exit

curl 127.0.0.1:8080
virsh destroy bootc-test
virsh undefine bootc-test --remove-all-storage
```

### Lab: Troubleshoot Bootc Containers and Their Containerfiles

```shell
cd
git clone https://github.com/RedHatQuickCourses/rhde-bootc-samples.git
podman login -u student -p redhat registry.lab.example.com:5000
podman image list | grep webapp-bootc
virsh list --all
ls temp-test-vm
ls temp-bootc
ls temp-bootc/oci

skopeo copy containers-storage:localhost/webapp-bootc oci:temp-bootc/oci:webapp-bootc
cd temp-test-vm
sed -i '1,$ s/httpd-bootc/webapp-bootc/g' inst.ks
bash virt-install.sh

curl 127.0.0.1:8080
ssh -i edge-key -p 8022 core@127.0.0.1

# sudo tail /var/log/httpd/access_log
# sudo tail /var/log/httpd/error_log
# ls -la /webapp
# ls -l /webapp/html
# sudo journalctl | grep avc:
# ls -laZ /webapp/html/

exit
virsh destroy bootc-test
virsh undefine bootc-test --remove-all-storage

cd ../rhde-bootc-samples
cd webapp-fixed
podman build -t webapp-fixed .
cd
skopeo copy containers-storage:localhost/webapp-fixed oci:temp-bootc/oci:webapp-fixed
cd temp-test-vm
sed -i '1,$ s/webapp-bootc/webapp-fixed/g' inst.ks
bash virt-install.sh

curl 127.0.0.1:8080

# optional steps skipped.

virsh destroy bootc-test
virsh undefine bootc-test --remove-all-storage
```

### Lab: Publish a Bootc Container in a Private Container Registry


```shell
cd
git clone https://github.com/RedHatQuickCourses/rhde-bootc-samples.git
podman login -u student -p redhat registry.lab.example.com:5000
podman image list | grep httpd-system

skopeo copy containers-storage:localhost/httpd-system docker://registry.lab.example.com:5000/httpd-system:v1.0-1234
scp temp-test-vm/edge-key.pub servera:~
scp utility:/opt/registry/certs/domain.crt servera:~
scp rhde-bootc-samples/bootc-install/bootc-install.sh servera:~

ssh servera
sudo dnf install -y bootc
bootc status
ip -br addr show
nmcli device status
nmcli connection show
nmcli -f ipv4.method connection show 'cloud-init ens3'

sudo cp domain.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract
sudo podman login -u student -p redhat registry.lab.example.com:5000
sudo podman pull registry.lab.example.com:5000/httpd-system:v1.0-1234
sudo bash bootc-install.sh


```
