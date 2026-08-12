# Compatibility Matrix: OCP 4.18 -- 4.22

This document tracks schema changes, feature availability, and configuration differences across the OpenShift versions covered by this repository.

## install-config.yaml schema

| Feature | 4.18 | 4.19 | 4.20 | 4.21 | 4.22 |
|---------|------|------|------|------|------|
| `apiVersion: v1` | Yes | Yes | Yes | Yes | Yes |
| `networkType: OVNKubernetes` | Only option | Only option | Only option | Only option | Only option |
| `imageDigestSources` (preferred) | Yes | Yes | Yes | Yes | Yes |
| `imageContentSources` (legacy mirror input) | Accepted | Accepted | Accepted | Accepted | Accepted |
| AWS `platform.aws.subnets` (flat list) | Yes | Deprecated | Deprecated | Deprecated | Deprecated |
| AWS `platform.aws.vpc.subnets` (with roles) | No | Yes | Yes | Yes | Yes |
| vSphere `vcenters[]` + `failureDomains[]` | Yes | Yes | Yes | Yes | Yes |
| vSphere legacy flat keys | Deprecated | Deprecated | Deprecated | Deprecated | Deprecated |

## agent-config.yaml schema

| Feature | 4.18 | 4.19 | 4.20 | 4.21 | 4.22 |
|---------|------|------|------|------|------|
| `apiVersion: v1beta1` | Yes | Yes | Yes | Yes | Yes |
| `kind: AgentConfig` | Yes | Yes | Yes | Yes | Yes |
| NMState `networkConfig` per host | Yes | Yes | Yes | Yes | Yes |
| `rendezvousIP` inference (static) | Yes | Yes | Yes | Yes | Yes |

## Cluster topologies

| Topology | 4.18 | 4.19 | 4.20 | 4.21 | 4.22 |
|----------|------|------|------|------|------|
| HA (3 control-plane + N workers) | GA | GA | GA | GA | GA |
| Compact / 3-node (schedulable masters) | GA | GA | GA | GA | GA |
| SNO (Single Node OpenShift) | GA | GA | GA | GA | GA |
| Two-Node with local arbiter (TNA) | Not available | Tech Preview | GA | GA | GA |
| Two-Node with fencing (TNF) | Not available | Not available | Tech Preview | Tech Preview | GA |

## oc-mirror

| Feature | 4.18 | 4.19 | 4.20 | 4.21 | 4.22 |
|---------|------|------|------|------|------|
| v1 (`mirror.openshift.io/v1alpha2`) | Deprecated | Deprecated | Deprecated | Deprecated | Deprecated |
| v2 (`mirror.openshift.io/v2alpha1`) | GA | GA | GA | GA | GA |
| Generated output: IDMS/ITMS | Yes | Yes | Yes | Yes | Yes |
| Generated output: ICSP (v1 only, deprecated) | Yes | Deprecated | Deprecated | Deprecated | Deprecated |

## Virtualization networking

| Feature | 4.18 | 4.19 | 4.20 | 4.21 | 4.22 |
|---------|------|------|------|------|------|
| OVN localnet (manual NAD) | GA | GA | GA | GA | GA |
| Linux bridge + `cnv-bridge` NAD | GA | GA | GA | GA | GA |
| OVS bridge + localnet NAD | GA | GA | GA | GA | GA |
| ClusterUserDefinedNetwork (localnet) | No | GA | GA | GA | GA |
| SR-IOV | GA | GA | GA | GA | GA |

## Operator channel mapping

See the `imageset-configs/` directory for per-release operator channel configurations. Key version-specific operators:

| Operator | 4.18 | 4.19 | 4.20 | 4.21 | 4.22 |
|----------|------|------|------|------|------|
| ACM | release-2.15 | release-2.16 | release-2.17 | release-2.17 | release-2.17 |
| MCE | stable-2.10 | stable-2.11 | stable-2.12 | stable-2.12 | stable-2.12 |
| ODF suite | stable-4.18 | stable-4.19 | stable-4.20 | stable-4.21 | stable-4.22 |
| LVMS | stable-4.18 | stable-4.19 | stable-4.20 | stable-4.21 | stable-4.22 |
| Quay | stable-3.14 | stable-3.15 | stable-3.16 | stable-3.17 | stable-3.18 |
| Logging | stable-6.4 | stable-6.5 | stable-6.6 | stable-6.6 | stable-6.6 |
| MTV | release-v2.10 | release-v2.11 | release-v2.12 | release-v2.12 | release-v2.12 |
| NVIDIA GPU | v26.3 | v26.3 | v26.3 | v26.3 | v26.3 |
| RHBK | stable-v26.6 | stable-v26.6 | stable-v26.6 | stable-v26.6 | stable-v26.6 |
| Service Mesh 3 | stable | stable | stable | stable | stable |
| AAP | stable-2.7 | stable-2.7 | stable-2.7 | stable-2.7 | stable-2.7 |

## Key differences to watch

### 4.18 to 4.19
- **ClusterUserDefinedNetwork** (CUDN) becomes GA for localnet topology
- **Two-Node with local arbiter (TNA)** enters Tech Preview
- **AWS VPC subnets** gains structured `vpc.subnets` with role-based assignment
- **oc-mirror v1** further deprecated (v2 is default)
- **ACM** moves from `release-2.15` to `release-2.16`
- **MCE** moves from `stable-2.10` to `stable-2.11`
- **ODF/LVMS** moves from `stable-4.18` to `stable-4.19`
- **Quay** moves from `stable-3.14` to `stable-3.15`
- **Logging** moves from `stable-6.4` to `stable-6.5`

### 4.19 to 4.20
- **Two-Node with local arbiter (TNA)** becomes GA
- **Two-Node with fencing (TNF)** enters Tech Preview
- **ACM** moves from `release-2.16` to `release-2.17`
- **MCE** moves from `stable-2.11` to `stable-2.12`
- **ODF/LVMS** moves to `stable-4.20`
- **Quay** moves from `stable-3.15` to `stable-3.16`
- **Logging** moves from `stable-6.5` to `stable-6.6`

### 4.20 to 4.21
- **ODF/LVMS** moves to `stable-4.21`
- **Quay** moves from `stable-3.16` to `stable-3.17`

### 4.21 to 4.22
- **Two-Node with fencing (TNF)** becomes GA
- **ODF/LVMS** moves to `stable-4.22`
- **Quay** moves from `stable-3.17` to `stable-3.18`
