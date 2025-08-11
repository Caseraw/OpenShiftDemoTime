#!/usr/bin/env bash

# Generate the DOT file
# ./graph.sh dev,sit,prod

NAMESPACES=$1

# Clear the file before writing
> bindings.txt

# Loop through namespaces
for ns in ${NAMESPACES//,/ }; do
  oc get rolebinding -n "$ns" -o json \
  | jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name) \(.roleRef.kind)/\(.roleRef.name) \(.subjects[]?.kind)/\(.subjects[]?.name)"' \
  >> bindings.txt
done

# Create DOT file
{
  echo "digraph RBAC {"
  echo "  rankdir=LR;"
  echo "  node [shape=cds, style=filled, fillcolor=lightblue];"

  while read namespace rolebinding role subject; do
    ns_node="\"NS:${namespace}\""
    rb_node="\"RB:${namespace}/${rolebinding}\""
    role_node="\"${role}\""
    subj_node="\"${subject}\""

    echo "  ${ns_node} -> ${rb_node};"
    echo "  ${rb_node} -> ${role_node};"
    echo "  ${role_node} -> ${subj_node};"
  done < bindings.txt

  echo "}"
} > bindings.dot
