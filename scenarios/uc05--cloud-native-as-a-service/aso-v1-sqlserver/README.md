# we will use CLI for this demo to talke about creating and deleting resources directluy from CLI
oc create -k scenarios/uc05--cloud-native-as-a-service/aso-v1-sqlserver

# this will pick up the kustomization.yaml file in this folder where all deployment resources are listed

resources:
- 01-azure-sql-server-secret.yaml
- 02-azure-sql-server.yaml
- 03-azure-sql-db.yaml
- 04-azure-sql-service.yaml