# Enable the virtualization dashboad on RHACM
oc annotate search search-v2-operator -n open-cluster-management virtual-machine-preview='true'
# then acccess the dashboard from RHACM web console