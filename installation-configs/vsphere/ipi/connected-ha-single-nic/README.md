# vSphere — IPI — Connected — HA — Single NIC

**Installer-provisioned** vSphere cluster with 3 control-plane and 3 worker nodes.
- `platform.vsphere` requires vCenter credentials and inventory targets (datacenter, cluster or resourcePool, datastore, PortGroup).
- **VIPs are required** for multi-node vSphere IPI: `apiVIPs` and `ingressVIPs`.

SSH key must be **public**; pullSecret must be **single-line JSON**.
