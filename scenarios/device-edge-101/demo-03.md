# Demo 03

Source: https://rhpds.github.io/edge-fleet-showroom/modules/index.html

## Show Fleet manager

- RHACM overview => Edge tab
- Show Fleet manager
- Show Fleet
- Edit Fleet (no changes)
- Show Devices

## Show Fleet manager

- Turn on VM
- Get QR code
- Approve device
- Go into terminal

```shell
cat /etc/redhat-release
bootc status
podman ps -a
```

- Join to the fleet
- Remove and add new label "pos=prod"
- Go into terminal

```shell
bootc status
podman ps -a
```

- Go to Application route

## Create new Fleet

- Create new Fleet

Name: lelystad-store-fleet
Device selector: fleet=lelystad
System image: image-registry.openshift-image-registry.svc:5000/student-services/rhel9-bootc-edgemanager-pos-prod:1.0.0
Application: quay.io/kenosborn/podman-compose:v2
Application name: new-pos-app

- Find our device
- Remove label and add "fleet=lelystad"
- Wait for redeployment
- Go to application route

## Break and heal

- Find the device
- Go to terminal
- Delete application pod

```shell
podman ps -a

podman kill -s 9 <ID>
```

- Go to application URL (broken now)
- Reboot VM


