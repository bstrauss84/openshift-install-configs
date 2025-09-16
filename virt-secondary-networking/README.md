# Secondary networking with OVN-Kubernetes

Order of operations:
1. Apply NNCP (NodeNetworkConfigurationPolicy, cluster-scoped) to configure node interfaces or bonds and VLANs.
2. Wait for NNCP status Available on all targeted nodes.
3. Apply NAD (NetworkAttachmentDefinition, namespaced) to define the attachment used by workloads.
4. Verify pod annotations and interfaces.

Multiple/secondary networks assume OVN-Kubernetes.
