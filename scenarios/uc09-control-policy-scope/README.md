# a development policy to deletect if deployments in specific namespace dv-ns with labels sla:ha are not 2 replicas
# using placement to select the target cluster
# using placement binding to link the policy to the placement

1 - create dev-ha-policy 
2 - create dev-placement placement
3 - create dev-ha-policy-placement placementbinding
4 - deploy a sample app with label sla:ha
5 - scale in and out to check policy violations