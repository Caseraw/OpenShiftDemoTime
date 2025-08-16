# Module 2

## 1) Review travel-agency namespace

Check pods from DevContainer:

```shell
oc get pods -n travel-agency

oc describe namespaces travel-agency
```

> Highlight the label `istio-injection=disabled`

## 2) Add travel-agency namespace to the mesh

Go to istio: http://kiali-istio-system.apps.<CLUSTER BASE DOMAIN>/

```
1) Filter on namespace `travel-agency`

2) Enable auto-injection.

3) Click on the `travel-agency` tile to show namespace labels.

4) Restart the pods (from DevContainer:):

oc get deployments -n travel-agency -o name \
  | xargs -I{} oc rollout -n travel-agency restart {}
```

## 3) Explore Traffic Graph

Go to: https://kiali-istio-system.apps.<CLUSTER BASE DOMAIN>/console/graph/namespaces

Filter on - `travel-agency` - `traffic` - `versioned app graph`

## 4) Explore Workload

Go to: https://kiali-istio-system.apps.<CLUSTER BASE DOMAIN>/console/graph/namespaces

Click on `Workload` on the left hand side menu.

Click on `travels-v1`.

## 5) Implement Least Privilege with Authorization Policies

Review the current access:

```shell
oc rsh -n travel-agency $(oc get pod -l app=travels -n travel-agency -o jsonpath='{.items[0].metadata.name}') \
  curl http://discounts.travel-agency.svc.cluster.local:8000/discounts/hello-from-travels
```

Apply the YAML:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: allow-only-trusted-services
  namespace: travel-agency
spec:
  selector:
    matchLabels:
      app: discounts
      version: v1
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/travel-agency/sa/discount-access-sa
```

Verify the access again:

```shell
oc rsh -n travel-agency $(oc get pod -l app=travels -n travel-agency -o jsonpath='{.items[0].metadata.name}') \
  curl http://discounts.travel-agency.svc.cluster.local:8000/discounts/hello-from-travels
```

## 6) Shape Traffic with OpenShift Service Mesh

Create `DestinationRule`:

```yaml
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: discounts
  namespace: travel-agency
spec:
  host: discounts
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

Create `VirtualService`:

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: discounts
  namespace: travel-agency
spec:
  hosts:
    - discounts
  http:
  - route:
    - destination:
        host: discounts
        subset: v1
        port:
          number: 8000
      weight: 100
    - destination:
        host: discounts
        subset: v2
        port:
          number: 8000
      weight: 0
```

Deploy V2 of Discounts:

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: discounts-v2
  namespace: travel-agency
spec:
  selector:
    matchLabels:
      app: discounts
      version: v2
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
        proxy.istio.io/config: |
          tracing:
            zipkin:
              address: zipkin.istio-system:9411
            sampling: 10
            custom_tags:
              http.header.portal:
                header:
                  name: portal
              http.header.device:
                header:
                  name: device
              http.header.user:
                header:
                  name: user
              http.header.travel:
                header:
                  name: travel
      labels:
        app: discounts
        version: v2
    spec:
      containers:
        - name: discounts
          image: quay.io/kiali/demo_travels_discounts:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            privileged: false
            readOnlyRootFilesystem: true
          env:
            - name: CURRENT_SERVICE
              value: "discounts"
            - name: CURRENT_VERSION
              value: "v2"
            - name: LISTEN_ADDRESS
              value: ":8000"
```

Split DevContainer terminal in 2:

Run this on 1:

```shell
sh <(curl -s https://raw.githubusercontent.com/app-connectivity-workshop/scripts/refs/heads/main/m2/canary-monitoring.sh)
```

Run this on 2:

```shell
sh <(curl -s https://raw.githubusercontent.com/app-connectivity-workshop/scripts/refs/heads/main/m2/canary-rollout.sh)
```

Watch terminal.  
Also watch Kiali webconsole on Traffic Graph

Optionally reset back to V1:

```shell
oc -n travel-agency patch virtualservice discounts --type=json -p='[
  {"op": "replace", "path": "/spec/http/0/route/0/weight", "value": 100},
  {"op": "replace", "path": "/spec/http/0/route/1/weight", "value": 0}
]'
```
