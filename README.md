# OpenShift Installation & Networking Configs (4.18--4.22)

Welcome! This repo is a documentation-accurate, heavily commented collection of:
- **Installation configs** (IPI, UPI, Agent) for **Bare Metal**, **AWS**, and **vSphere**
- **ImageSet configs** (oc-mirror **v1** and **v2**) with "golden" and split variants
- **Utility-box** building blocks (DNS/DHCP/NTP, mirror-registry, load balancer)
- **Virtualization networking** scenarios (NMState + Multus/NAD, VMs)
- **Validation scripts** and CI for config correctness

**Fake Environment (authoritative reference)**
- Base domain: `example.com`
- Cluster name: `cluster`
- Machine network CIDR: `10.90.0.0/24`
- VIPs:
  - API: `10.90.0.10`
  - Ingress: `10.90.0.11`
- Masters: `cluster-master-{1,2,3}` at `10.90.0.{21,22,23}`
- Workers: `cluster-worker-{1,2,3}` at `10.90.0.{51,52,53}`
- DNS server: `10.90.0.3`
- Gateway: `10.90.0.1`
- DNS records:
  - `api.cluster.example.com` → `10.90.0.10`
  - `api-int.cluster.example.com` → `10.90.0.10`
  - `*.apps.cluster.example.com` → `10.90.0.11`
- DHCP guidance:
  - Reserve host MAC→IP leases for control-plane/worker nodes
  - Option 3 (gateway): subnet default GW
  - Option 6 (DNS): authoritative DNS (e.g., `10.90.0.3`)
  - Option 15 (domain): `example.com`
  - Option 119 (search): `cluster.example.com, example.com`
  - Option 42 (NTP) if needed
- Host addressing: nodes use static or reserved DHCP in `10.90.0.x`
- VLANs `100`, `200`

We favor **block YAML** (JSON only where required, e.g., `pullSecret`), opt for **clear comments**.

> When in doubt, **official OpenShift and RHEL documentation take precedence**. See [`SOURCES.md`](./SOURCES.md) for direct links to the exact sections used.

> See [`COMPATIBILITY.md`](./COMPATIBILITY.md) for a version-by-version feature and schema matrix covering OCP 4.18--4.22.

---

## Repository Layout

```
openshift-install-configs/
├── imageset-configs/
│   ├── 4.18/
│   │   ├── v1/             # oc-mirror v1 (deprecated, legacy reference only)
│   │   └── v2/             # oc-mirror v2
│   ├── 4.19/
│   │   └── v2/
│   ├── 4.20/
│   │   └── v2/
│   ├── 4.21/
│   │   └── v2/
│   └── 4.22/
│       └── v2/
├── installation-configs/
│   ├── aws/
│   │   ├── ipi/            # connected & proxied
│   │   └── upi/            # connected (preexisting VPC)
│   ├── baremetal/
│   │   ├── agent/          # 9 variants (connected/disconnected/proxied, HA/3node/SNO, static/DHCP, bond/single-nic, FIPS, dual-stack, multi-VLAN-storage)
│   │   ├── ipi/            # connected (bond) & proxied
│   │   └── upi/            # connected & proxied
│   └── vsphere/
│       ├── ipi/            # connected (multi-FD) & proxied (single-FD, modern schema)
│       └── upi/            # connected (multi-FD) & proxied (single-FD)
├── utility-box/
│   ├── all-in-one-dnsmasq/ # single-file DNS+DHCP+NTP (recommended starting path)
│   ├── broken-out/         # dns/ dhcp/ ntp/ individually
│   ├── load-balancer/      # canonical HAProxy for external LB scenarios
│   └── mirror-registry/    # mini-quay (mirror registry) walkthrough
├── virtualization-networking-configs/
│   ├── bond-bridge-dedicated-nics/   # bond + Linux bridge (cnv-bridge)
│   ├── cudn-localnet/                # ClusterUserDefinedNetwork localnet (4.19+)
│   ├── linux-bridge-dedicated-nic/   # Linux bridge (cnv-bridge)
│   ├── multi-vlan-ovs/              # OVS trunk for multi-VLAN
│   ├── ovs-bridge-dedicated-nic/    # OVS bridge + OVN localnet
│   └── single-nic-br-ex-localnet/   # OVN localnet on br-ex (single NIC)
├── scripts/validate/        # validation scripts (also used in CI)
├── COMPATIBILITY.md          # OCP 4.18--4.22 feature/schema matrix
└── SOURCES.md                # official doc links organized by topic
```

Each scenario directory contains:
- `install-config.yaml` (and `agent-config.yaml` for Agent)
- `README.md` (how to use, what to change, what each field means)
- `scenario.yaml` (short metadata with `targetReleases`, `tokens`, etc.)

> **`targetReleases`**: OpenShift minor releases for which the example is intended and has been reviewed for configuration/API applicability. This does not imply that the scenario was physically installed and tested on every listed release.

---

## Quick Starts

### Installation Configs
- **IPI**: Installer creates & controls infra (AWS/VPC + ELB/ALB, vSphere w/ VIPs, Bare Metal w/ VIPs).
- **UPI**: You provide infra (LB, DNS, compute, boot path).
- **Agent**: ISO/PXE-based flow; static/DHCP networking via **NMState** in `agent-config.yaml`.

Common patterns across scenarios:
- **SSH public key**: provide your **public** key (e.g., `~/.ssh/id_ed25519.pub`). Generate one:
  ```bash
  ssh-keygen -t ed25519 -C "you@host" -f ~/.ssh/id_ed25519
  cat ~/.ssh/id_ed25519.pub
  ```
- **pullSecret**: must be **single-line JSON**. Collapse a multi-line file:
  ```bash
  tr -d '\n' < pull-secret.json
  # or
  jq -c . < pull-secret.json
  ```
- **Proxy** (proxied scenarios): include `proxy:` (`httpProxy`, `httpsProxy`, `noProxy`), plus `additionalTrustBundle` (PEM)
  and `additionalTrustBundlePolicy: Always`.
- **Disconnected**: prefer **`imageDigestSources`** (oc-mirror v2); `imageContentSources` is deprecated (v1) and kept only as a commented example.

### ImageSet Configs (oc-mirror)
- `imageset-configs/*/v2/`: oc-mirror v2 format, with `golden_all.yaml` (categorized operator blocks) and exact split variants:
  - `platform-only.yaml`
  - `operators-only.yaml`
  - `additionalimages-only.yaml`
- `imageset-configs/4.18/v1/`: oc-mirror v1 format (deprecated, retained for legacy reference).

Operator channels are verified against official Red Hat catalogs and lifecycle pages for each OCP release.

**Where to get oc-mirror**: use the official client index to pick the exact OCP version (and RHEL 8/9 build) you need:  
<https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/>

### Utility-Box
- **dnsmasq (all-in-one)** doing DNS+DHCP+NTP (recommended starting point).
- **Broken-out** services (`dns/`, `dhcp/`, `ntp/`) if you want separation-of-concerns.
- **Load balancer**: canonical **HAProxy** for any external LB scenario (UPI, agent+extlb). Workers are the default ingress backend (standard HA); compact/3-node is documented as a commented variation.
- **Mirror registry**: doc-accurate **mini-quay** walkthrough for OCP 4.18+ on RHEL 9 (with RHEL 8 notes).

### Virtualization Networking
- Six curated examples covering OVS bridges, Linux bridges, bond+bridge, OVN localnet, and ClusterUserDefinedNetwork (CUDN).
- Each has `nncp.yaml` (or `cudn.yaml`), `nad.yaml` (where applicable), and `vm.yaml`.
- READMEs cover how to apply and safely roll back NNCP (`state: absent`), and caveats (don't build new bridges on the same NIC as `br-ex` without care).
- CUDN localnet scenario requires OCP 4.19+ (GA).

---

## Validation

Run the validation suite locally:

```bash
# All checks
scripts/validate/yaml-syntax-check.sh
scripts/validate/check-rendezvous-ip.sh
scripts/validate/check-scenario-metadata.sh
scripts/validate/check-golden-split.sh
scripts/validate/check-cross-file-consistency.sh
```

CI runs these checks automatically on push/PR via GitHub Actions (`.github/workflows/validate.yaml`).

---

## FIPS Installations

If you set `fips: true` in `install-config.yaml`:
- Use the **FIPS-enabled OpenShift installer** matching your OCP version.
- Run installation from a **FIPS-enabled RHEL 9** host.
- Download from the official client index:  
  <https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/>

---

## Contributing

1. Open an issue describing your enhancement or scenario gap.
2. Use **block YAML** and preserve the **comment style** used across the repo.
3. Keep comments **next to** the fields they describe; mark optional keys clearly.
4. Prefer **official docs** and RH blogs over random community posts.
5. If you change templates or scripts, keep original comments and structure--augment, don't overwrite.
6. Run `scripts/validate/*.sh` before submitting a PR.

We will continue to expand and tune this repo over time.

---

## License

Unless otherwise noted, content is provided as-is. Review license headers in subtrees where present.
