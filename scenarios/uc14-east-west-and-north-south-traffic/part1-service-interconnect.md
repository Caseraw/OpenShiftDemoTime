# Module 1

## 1) Check initial connection

Check connection from showroom terminal:

```shell
curl travels.travel-agency.svc.cluster.local:8000/travels/Prague && echo

# RESULT

{"error":"Travel Quote for Prague not found"}
```

## 2) Create a site

Go to and create site:

```
OCP Webconsole => Home => Projects => "travel-db" => Service Interconnect (tab) => Create Site

## Wait for the site to be ready.

OCP Webconsole => Home => Projects => "travel-db" => Service Interconnect (tab) => Details (sub tab) => State is ready
```

## 3) Create a listener

Go to and create a listener:

```
OCP Webconsole => Home => Projects => "travel-db" => Service Interconnect (tab) => Create a listener

# Name:         mysqldb
# Port:         3306
# Routing key:  appconn
# Host:         mysqldb
```

## 4) Generate a token

Go to and generate a token:

```
OCP Webconsole => Home => Projects => "travel-db" => Service Interconnect (tab) => Generate a token

# FileName:         my-grant
# Redemptions:      1
# Code:             leave this blank
# Valid for:        60 minutes
```

## 5) Deploy Red Hat Service Interconnect Network Console

Run this from DevContainer:

```shell
oc apply -f https://raw.githubusercontent.com/app-connectivity-workshop/scripts/refs/heads/main/m1/network_console_deploy.yaml -n travel-db

```

## 6) Log in on RHEL and validate the environment

Run this from Showroom bastion:

```shell
podman ps
```

## 7) Create Red Hat Service Interconnect Site

Run this from Showroom bastion:

```shell
export SKUPPER_PLATFORM=podman 
skupper site create rhel
```

## 8) Create a connector

Run this from Showroom bastion:

```shell
skupper connector create mysqldb 3306 --host 127.0.0.1 -r appconn
```

## 9) Visualise set up on Red Hat Service Interconnect Network Console

Go to and log in: https://skupper-network-observer-travel-db.apps.cluster-v5zjb.v5zjb.sandbox5571.opentlc.com/#/topology?type=Sites

Show topology.

## 10) Complete the access configuration

Run this from DevContainer:

```shell
curl -s https://raw.githubusercontent.com/app-connectivity-workshop/scripts/refs/heads/main/m1/convert_grant_token.sh | bash > summit_token.yaml

scp summit_token.yaml <USER>@<HOST>:/home/lab-user/.local/share/skupper/namespaces/default/input/resources/
```

Run this from Showroom Bastion:

```shell
skupper system setup
```

## 11) Verify DB connectivity

Run this from Showroom Terminal:

```shell
curl travels.travel-agency.svc.cluster.local:8000/travels/Prague | jq
```

