# SOURCES

This repo’s content aligns with the following Red Hat documentation. Use these when adapting examples:

- Agent-based installer, preferred inputs, `AgentConfig v1alpha1`, and building the agent ISO with `openshift-install --dir . agent create image`:
  - Installing with the Agent-based Installer (OCP 4.18 and earlier chapters): https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_an_on-premise_cluster_with_the_agent-based_installer/installing-with-agent-based-installer
  - Preparing to install (OCP 4.12–4.17 samples mention `AgentConfig v1alpha1` and `rendezvousIP`): https://docs.redhat.com/en/documentation/openshift_container_platform/4.12/html/installing_an_on-premise_cluster_with_the_agent-based_installer/preparing-to-install-with-agent-based-installer
  - Agent ISO command sample (4.12): https://docs.redhat.com/en/documentation/openshift_container_platform/4.12/html/installing_an_on-premise_cluster_with_the_agent-based_installer/installing-with-agent-based-installer

- Install config reference and samples (`apiVersion: v1`, `networkType: OVNKubernetes`, explanation of networks):
  - Installing on any platform (4.18 PDF with `install-config.yaml` samples): https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/pdf/installing_on_any_platform/OpenShift_Container_Platform-4.18-Installing_on_any_platform-en-US.pdf

- OVN default and SDN deprecation:
  - OVN-Kubernetes is deployed by the Cluster Network Operator and is the default in current releases: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/networking_operators/cluster-network-operator
  - SDN deprecated; not an option for new installs in later releases: https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/networking/ovn-kubernetes-network-plugin

- Bare metal VIP behavior (keepalived/haproxy provided by the installer when VIPs are set):
  - Bare metal installing docs (4.19 PDF—API VIP lifecycle with keepalived): https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/pdf/installing_on_bare_metal/OpenShift_Container_Platform-4.19-Installing_on_bare_metal-en-US.pdf
  - Older bare metal docs explaining API VIP behavior: https://docs.redhat.com/en/documentation/openshift_container_platform/4.10/html/installing/deploying-installer-provisioned-clusters-on-bare-metal

- `additionalTrustBundlePolicy: Always` supported with Agent-based in 4.18+:
  - 4.18 release notes item: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/release_notes/ocp-4-18-release-notes

- Mirroring and oc-mirror plugin:
  - oc-mirror v1 docs and examples (`mirror.openshift.io/v1alpha2`): https://docs.redhat.com/en/documentation/openshift_container_platform/4.15/html-single/disconnected_installation_mirroring/
  - oc-mirror v2 docs (`mirror.openshift.io/v2alpha1`, `--workspace`, resource locations): https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/disconnected_installation_mirroring/about-installing-oc-mirror-v2
  - Disconnected environments overview (4.18) noting v1→v2 API changes: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/disconnected_environments/mirroring-in-disconnected-environments

- NMState and secondary networks:
  - Kubernetes NMState (NNCP `nmstate.io/v1`): https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/kubernetes_nmstate/index
  - NetworkAttachmentDefinition (`k8s.cni.cncf.io/v1`): https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/network_apis/networkattachmentdefinition-k8s-cni-cncf-io-v1

- Image mirroring deprecation note:
  - `imageContentSources` deprecated warning; use `imageDigestSources`: https://access.redhat.com/solutions/7080678

- AWS special regions:
  - AWS GovCloud: https://docs.redhat.com/en/documentation/openshift_container_platform/4.12/html/installing_on_aws/installing-aws-government-region
  - SC2S/C2S and related fixes: https://docs.redhat.com/en/documentation/openshift_container_platform/4.14/html/installing_on_aws/installing-aws-secret-region and 4.18 release notes item fixing load balancer SGs: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/release_notes/ocp-4-18-release-notes

<!-- __GS_DOC_ANCHOR__ -->
## Key Red Hat docs referenced for this scaffold

- oc-mirror v2 (ImageSetConfiguration v2alpha1, workspace, outputs): https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html-single/disconnected_installations_and_updates/#oc-mirror-v2-ref_disconnected-oc-mirror
- ImageSetConfiguration v2alpha1 API PDF: https://repo1.dso.mil/big-bang/product/packages/loki/-/raw/main/docs/OpenShift_Container_Platform-4.14-ImageSetConfiguration_v2alpha1-1-en-US.pdf
- Agent-based installer (4.18+), AgentConfig version and agent ISO: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_an_on-premise_cluster_with_the_agent-based_installer/preparing-to-install-with-agent-based-installer
- Bare metal IPI host networkConfig and VIP lists: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_bare_metal/installer-provisioned-infrastructure#configuring-host-network-interfaces-in-the-install-config-yaml-file_ipi-install-installation-workflow
- additionalTrustBundlePolicy and install-config field behavior (example reference): https://docs.redhat.com/en/documentation/openshift_container_platform/4.12/html/installing_on_gcp/installing-on-gcp#installation-configuration-parameters_installing-gcp
- Installing on any platform (install-config reference, general behaviors): https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/installing_on_any_platform/
