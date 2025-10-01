# Sources & References (OCP 4.18 focus; RHEL 9 where applicable)

Priority order: **Official OpenShift docs** > **RH solution/knowledge articles** > **RH engineering/product blogs** > **Upstream (NMState/Multus)**.

---

## Global / Clients / oc-mirror

- **OpenShift Client downloads (oc / oc-mirror, per OCP version and OS)**  
  https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/  
  *Pick the exact OCP version and platform (RHEL 8/9) to download oc/oc-mirror; includes checksums and signatures.*

- **Disconnected mirroring (oc-mirror v2 workflow)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/disconnected_environments/mirroring-in-disconnected-environments  
  *Mirror to disk, disk to mirror, mirror to mirror; location of generated cluster resources; high-level prerequisites.*

- **ImageContentSourcePolicy vs ImageDigestMirrorSet / ImageTagMirrorSet** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/images/image-configuration  
  *Explains deprecation of ICSP (v1-era) in favor of IDMS/ITMS (v2-era); how the cluster consumes mirrored images.*

- **oc-mirror v2 CLI reference (flags & workflows)**  
  (use `oc-mirror --v2 --help` and the per-version docs above; flags like `--cache-dir`, `--parallel-images`, `--parallel-layers`, `--retry-delay`, `--retry-times` are especially useful)

---

## Installation Configs

### Bare Metal

- **Installing a cluster on bare metal (IPI)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_bare_metal/installer-provisioned-infrastructure  
  *Bare metal IPI workflow, VIP semantics, provisioning network details, BMC drivers, boot modes.*

- **Bare metal UPI** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_bare_metal/user-provisioned-infrastructure  
  *UPI responsibilities, external load balancer and DNS expectations.*

- **Agent-based installer** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_an_on-premise_cluster_with_the_agent-based_installer/installing-with-agent-based-installer  
  *Agent-based flow, `install-config.yaml` + `AgentConfig` (`v1beta1`), generating ISO, rendezvous IP, NMState in `networkConfig`.*

- **Preparing to install on bare metal (host networking in install-config)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_bare_metal/preparing-to-install-on-bare-metal  
  *Inline NMState for IPI when specifying host networking.*

- **Proxy configuration (install-config & cluster)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/configuring_network_settings/enable-cluster-wide-proxy  
  *`proxy:` in `install-config.yaml`, trusted CAs, `Proxy` object semantics.*

- **FIPS mode** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installation_overview/installing-fips  
  *FIPS pre-reqs, use of FIPS-enabled installer, host OS considerations.*

- **Example (educational)** — IPI on bare metal with rich commentary (external reference)  
  https://hackmd.io/@johnsimcall/rJ6Y9jN9ex  
  *Field usage patterns and comments that inspired several inline notes here.*

### AWS

- **Installing a cluster on AWS (IPI)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_aws/installer-provisioned-infrastructure  
  *Installer-managed VPC, subnets, security groups, ELB/ALB; `platform.aws` fields.*

- **User-provisioned infrastructure on AWS (UPI)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_aws/user-provisioned-infrastructure  
  *UPI responsibilities: external load balancer, DNS, EC2, IAM; `platform: none` usage.*

- **AWS-specific install-config parameters** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_aws/installation-config-parameters-aws  
  *`platform.aws` fields: region, subnets, defaultMachinePlatform, rootVolume, zones, tags, serviceEndpoints.*

- **Proxy configuration** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/configuring_network_settings/enable-cluster-wide-proxy  
  *Cluster-wide proxy and trust bundles; `noProxy` considerations.*

### vSphere

- **Installing a cluster on vSphere (IPI)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_vmware_vsphere/installer-provisioned-infrastructure  
  *`platform.vsphere` fields: vCenter, datacenter, datastore, cluster/resourcePool, network/PortGroup; VIP requirements.*

- **User-provisioned infrastructure on vSphere (UPI)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_vmware_vsphere/user-provisioned-infrastructure  
  *UPI on vSphere responsibilities; `platform: none`; external LB and DNS requirements.*

- **vSphere-specific install-config parameters** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_vmware_vsphere/installation-config-parameters-vsphere  
  *Parameter table and examples; VIP list semantics (`apiVIPs`, `ingressVIPs`).*

- **Proxy configuration** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/configuring_network_settings/enable-cluster-wide-proxy  
  *Same proxy/trust guidance as other platforms.*

---

## Virtualization Networking (OpenShift Virtualization + NMState + Multus)

- **Blog: Access external networks with OpenShift Virtualization** (Red Hat)  
  https://www.redhat.com/en/blog/access-external-networks-with-openshift-virtualization  
  *br-ex `localnet`, OVS bridge on dedicated NIC, Linux bridge on dedicated NIC; NAD and VM attachment examples.*

- **NMState Operator concepts (NNS/NNCP/NNCE)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/networking_operators/k8s-nmstate-about-the-k8s-nmstate-operator  
  *CRDs, desired vs current state, policy enactments.*

- **Configure node network with NMState (NNCP)** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/kubernetes_nmstate/k8s-nmstate-updating-node-network-config  
  *NNCP YAML structure, `state:` usage, safe rollback.*

- **Multiple networks — concepts & configuration** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/multiple_networks/understanding-multiple-networks  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/multiple_networks/index  
  *Multiple networks concepts, NetworkAttachmentDefinition with OVN localnet and Linux bridge types.*

- **OpenShift Virtualization (CNV) VMs** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/virtualization/creating-a-virtual-machine  
  *VM NIC configuration and expectations when attached to additional networks.*

---

## Utility Box (RHEL 9 focus)

- **dnsmasq (RHEL 9)** — `man dnsmasq` and RHEL docs  
  https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9  
  *DHCP options (human-readable forms like NTP), DNS caching/forwarding, reservations.*

- **chrony (RHEL 9)**  
  https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/configuring-time-synchronization_configuring-basic-system-settings  
  *`chronyd` server config examples and best practices.*

- **HAProxy (RHEL 9)**  
  https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_networking/using-load-balancers_configuring-and-managing-networking  
  *Layer-4 passthrough vs Layer-7, TLS passthrough for API/API-int/apps routes.*

- **Mirror registry (Quay) for OpenShift** — OCP 4.18  
  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/disconnected_environments/mirroring-in-disconnected-environments  
  *“Mirror registry” (mini-quay) installation steps, certs, auth integration with oc-mirror. Notes for RHEL 9/8.*

---

## Upstream / Supporting

- **NMState**  
  https://nmstate.io/  
  *Schema and examples for interface, VLAN, bond, routes, DNS resolver sections.*

- **Multus**  
  https://github.com/k8snetworkplumbingwg/multus-cni  
  *CNI chaining, NAD spec reference.*
