# Module 3

## 1) Explore Red Hat Connectivity Link set up (Platform Enigneer)

Go to and explore: `OCP Webconsole => Connectivity Link => Overview`

Give quick overview.

Try the `echo-api` HTTPRoute.

```shell
curl -k -w "%{http_code}" https://echo.travels.<SANDBOX BASE DOMAIN> && echo
```

Apply `AuthPolicy` to protect the route:

```yaml
apiVersion: kuadrant.io/v1
kind: AuthPolicy
metadata:
  name: prod-web-deny-all
  namespace: ingress-gateway
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: prod-web
  rules:
    authorization:
      deny-all:
        opa:
          rego: "allow = false"
    response:
      unauthorized:
        headers:
          "content-type":
            value: application/json
        body:
          value: |
            {
              "error": "Forbidden",
              "message": "Access denied by default by the gateway operator. If you are the administrator of the service, create a specific auth policy for the route."
            }
```

Setup ratelimiting:

```yaml
apiVersion: kuadrant.io/v1
kind: RateLimitPolicy
metadata:
  name: ingress-gateway-rlp-lowlimits
  namespace: ingress-gateway
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: prod-web
  limits:
    "default-limits":
      rates:
      - limit: 5
        window: 10s
```

Run this script to hit ratelimit:

```shell
for i in {1..10}; do echo "($i)"; curl -k -w "%{http_code}" https://echo.travels.<SANDBOX BASE DOMAIN>; echo; done
```

# 2) Developer workflow

In OCP Web console access the workload topology of namespace `travel-web`.

Open the Application route and see this issue on the site.

Apply this `HTTPRoute`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: travel-agency
  namespace: travel-agency
  labels:
    deployment: travels-v1
    service: travels
spec:
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: prod-web
      namespace: ingress-gateway
  hostnames:
    - api.travels.<SANDBOX BASE DOMAIN>
  rules:
    - backendRefs:
        - group: ''
          kind: Service
          name: travels
          namespace: travel-agency
          port: 8000
          weight: 1
      matches:
        - path:
            type: PathPrefix
            value: /
```

Checkout the Travel webpage app again, reload.

Setup `AuthPolicy`:

```yaml
apiVersion: kuadrant.io/v1
kind: AuthPolicy
metadata:
  name: travel-agency-authpolicy
  namespace: travel-agency
spec:
  defaults:
    rules:
      authentication:
        api-key-authn:
          apiKey:
            allNamespaces: false
            selector:
              matchLabels:
                app: partner
          credentials:
            queryString:
              name: APIKEY
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: travel-agency

---
apiVersion: v1
kind: Secret
metadata:
  name: apikey-blue
  namespace: kuadrant-system
  labels:
    authorino.kuadrant.io/managed-by: authorino
    app: partner
stringData:
  api_key: blue
type: Opaque
```

Checkout the Travel webpage app again, reload.

Create new ``:

```yaml
apiVersion: kuadrant.io/v1
kind: RateLimitPolicy
metadata:
  name: ratelimit-policy-travels
  namespace: travel-agency
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: travel-agency
  limits:
    "per-user":
      rates:
        - limit: 20
          window: 10s
      counters:
        - expression: auth.identity.userid
```

Open Grafana: https://grafana-route-monitoring.apps.<CLUSTER BASE DOMAIN>/

Go to Dashboard => monitoring=> App Developer Dashboard

Run this script:

```shell
for i in {1..1000}; do curl -k -w "%{http_code}" https://echo.travels.<SANDBOX BASE DOMAIN>; done
```

Go to Platform Engineer Dashboard.

Go to Business User Dashboard.


