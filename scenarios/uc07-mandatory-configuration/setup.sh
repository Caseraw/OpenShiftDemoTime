#htpasswd -c -B -b htpasswd user1 redhat123
#htpasswd -b htpasswd user2 redhat123
#htpasswd -b htpasswd user3 redhat123
#htpasswd -b htpasswd user4 redhat123

# configure htpasswd identity provider
oc create secret generic htpasswd-secret \
  --from-file htpasswd=htpasswd -n openshift-config
oc replace -f oauth.yaml
oc get po -n openshift-authentication -w

# create namespace config template with default configuration
oc create -f namespaceconfig.yaml