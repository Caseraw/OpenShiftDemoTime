# Demo - Use Case 12 - Deny All - Zero trust

This scenario covers the the us of NetworkPolicies in the context of a backend
and frontend application that is pread acros 2 namespaces.

## Prerequisites

### UC19 Network Graphs

Everything relies on the environment set up like the scenario [UC19 Network
Graphs](../uc19-network-graphs/README.md). For more on the setup please checkout
the instructions.

## Demo storyline

- Explore the backend and frontend without the use of NetworkPolicies.
- Add Deny All and build up the required NetworkPolicies to allow traffic.
  - Do this per namespace "backend" "frontend".
- Eventually make everything work again.
