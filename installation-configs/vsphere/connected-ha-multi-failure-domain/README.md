# vSphere — IPI — Connected — HA — Multi Failure Domains

Deploy a 3×control-plane + 3×worker cluster across **three vSphere failure domains** (same vCenter/DC, different clusters/datastores).  
Uses modern `platform.vsphere.vcenters[]` and `failureDomains[]` plus **VIPs** (`apiVIPs`, `ingressVIPs`).

**Why this scenario?** Spreads nodes across zones for better availability while staying in one vCenter/DC.  
VIPs are required for vSphere IPI. The installer creates the VMs, configures VIPs, and wires up NSX/vSwitch networking.  
Docs: vSphere platform parameters & failure domains. :contentReference[oaicite:2]{index=2}
