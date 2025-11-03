# Demo 01

Source: https://redhatquickcourses.github.io/rhde-build/rhde-build/1/index.html

## Prepare workstation

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

sudo mkdir -p /etc/osbuild-composer/repositories && \
sudo cp /usr/share/osbuild-composer/repositories/rhel-9.5.json /etc/osbuild-composer/repositories/
sudo curl -L -o /etc/osbuild-composer/repositories/rhel-9.5.json https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/repositories/rhel-9.5.json && \
sudo systemctl stop osbuild-worker@1.service && \
sudo systemctl restart osbuild-composer && \
wget -q http://content.example.com/rhde/isos/rhel-9.5-x86_64-boot.iso && \
ssh-keygen -R servera && \
curl -L -o rhel9-httpd.ks https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/ks/rhel9-httpd.ks && \
scp rhel9-httpd.ks servera.lab.example.com:~
```

## Prepare blueprint and image build on workstation

```shell
curl -L -o rhel9-httpd.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-httpd.toml && \
composer-cli blueprints push rhel9-httpd.toml && \
composer-cli blueprints list && \
composer-cli blueprints show rhel9-edge && \
composer-cli blueprints depsolve rhel9-edge && \
composer-cli compose start-ostree rhel9-edge edge-commit && \
composer-cli compose list running && \
UUID=$(composer-cli compose list running | awk 'NR==2 {print $1}') && \
echo $UUID

# Wait for image build to finish

composer-cli compose image $UUID --filename rhel9-httpd-commit.tar && \
scp rhel9-httpd-commit.tar servera.lab.example.com:~
```

## Prepare OStree webserver on servera

```shell
sudo dnf -y install httpd rpm-ostree ostree && \
sudo systemctl enable httpd --now && \
sudo firewall-cmd --add-service=http --permanent && \
sudo firewall-cmd --reload && \
sudo tar xf ~/rhel9-httpd-commit.tar -C /var/www/html && \
sudo cp rhel9-httpd.ks /var/www/html && \
sudo chmod -R a+X /var/www/html && \
sudo restorecon -R /var/www/html && \
sudo rm /var/www/html/compose.json
```

## Run initial VM on workstation

```shell
virt-install --name edge-test-1 --os-variant rhel9.5 \
--memory 2048 --vcpus 2 --disk size=10 --graphics=none \
--location rhel-9.5-x86_64-boot.iso \
--extra-arg inst.ks=http://servera.lab.example.com/rhel9-httpd.ks \
--extra-arg console=ttyS0 -v
```

## Run an update on the image on workstation

```shell
curl -l -o rhel9-httpd-v2.toml https://raw.githubusercontent.com/RedHatQuickCourses/rhde-build-samples/refs/heads/main/blueprints/rhel9-httpd-v2.toml && \
composer-cli blueprints push rhel9-httpd-v2.toml && \
composer-cli blueprints show rhel9-edge && \
composer-cli compose start-ostree rhel9-edge edge-commit --url http://servera.lab.example.com/repo --ref rhel/9/x86_64/edge && \
composer-cli compose list running && \
UUID=$(composer-cli compose list running | awk 'NR==2 {print $1}') && \
echo $UUID

# Wait for image build to finish

composer-cli compose image $UUID --filename rhel9-httpd-v2-commit.tar && \
scp rhel9-httpd-v2-commit.tar servera:~
```

## Update the OStree on servera

```shell
mkdir delete-me && \
tar xf rhel9-httpd-v2-commit.tar -C delete-me/ && \
sudo ostree pull-local --repo=/var/www/html/repo delete-me/repo && \
sudo ostree summary -u --repo=/var/www/html/repo && \
rm -rf delete-me
```

## Run the device update to new image and roll back

```shell
virsh console edge-test-1

sudo rpm-ostree status
sudo rpm-ostree upgrade --check
sudo rpm-ostree upgrade
sudo systemctl reboot

rpm -q cockpit
sudo rpm-ostree status
sudo rpm-ostree rollback
sudo systemctl reboot
sudo rpm-ostree status
```

