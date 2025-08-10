htpasswd -c -B -b htpasswd user1 redhat123
htpasswd -b htpasswd user2 redhat123
htpasswd -b htpasswd user3 redhat123
htpasswd -b htpasswd user4 redhat123

htpasswd -b htpasswd wael redhat123
htpasswd -b htpasswd kasra redhat123
htpasswd -b htpasswd marc redhat123


# configure oauth with htpasswd identity provider
oc delete secret htpasswd-secret -n openshift-config
oc create secret generic htpasswd-secret \
  --from-file htpasswd=htpasswd -n openshift-config

oc get po -n openshift-authentication -w