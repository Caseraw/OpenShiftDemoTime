# Enable the virtualization dashboad on RHACM
# https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html/virtualization/acm-virt#enable-vm-actions
oc annotate search search-v2-operator -n open-cluster-management virtual-machine-preview='true'
# then acccess the dashboard from RHACM web console