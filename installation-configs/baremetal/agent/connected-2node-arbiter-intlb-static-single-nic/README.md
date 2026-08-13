# Bare Metal -- Agent -- Connected Two-Node with Arbiter (Static, Single-NIC)

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Two-Node with local arbiter (TNA)**: 2 control-plane nodes + 1 lightweight arbiter for etcd quorum.
- **`controlPlane.replicas: 2`** with a top-level **`arbiter:`** block (`replicas: 1`, `name: arbiter`).
- **`compute.replicas: 0`** in this example: control-plane nodes are schedulable. Day-2 workers are optional.
- **`role: arbiter`** in `agent-config.yaml`: the arbiter host uses a distinct role, not `master` or `worker`.
- **Arbiter requirements**: 2 vCPU, 8 GB RAM, 50 GB SSD. End-to-end latency (network + disk I/O) < 500ms.
- **Internal load balancer**: installer-managed VIPs (`apiVIPs` / `ingressVIPs`).
- **Static single-NIC networking** via NMState in `agent-config.yaml`.
- **GA in OCP 4.20+**. Tech Preview in 4.19 (requires `featureSet: TechPreviewNoUpgrade`, not shown).

## What the arbiter does
The arbiter runs only the third etcd member. It does NOT run kube-apiserver, kube-controller-manager, or user workloads. It carries the taint `node-role.kubernetes.io/arbiter:NoSchedule`.

Post-install node roles:
```
cluster-arbiter-1   Ready   arbiter
cluster-master-1    Ready   control-plane,master,worker
cluster-master-2    Ready   control-plane,master,worker
```

## Notes
- The `arbiter:` block is a top-level field in `install-config.yaml` (same level as `controlPlane:` and `compute:`).
- `arbiter.name` must be the literal string `"arbiter"`.
- `arbiter.replicas` must be exactly `1`.
- The `arbiter:` block is only valid when `controlPlane.replicas == 2`.
- Supported platforms for arbiter: `baremetal` (4.20--4.21); `baremetal`, `external`, `none` (4.22+).
- For IPI, the arbiter host also appears in `platform.baremetal.hosts[]` with `role: arbiter` and BMC credentials.
- For high-latency arbiter placement, apply the etcd slow profile post-install.
