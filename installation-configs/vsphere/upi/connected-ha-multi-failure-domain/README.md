# vSphere — UPI — Connected — HA — Multi Failure Domains

You create all vSphere resources (VMs, LBs, DNS). The installer provides Ignition only.  
Operationally mirror the IPI “multi-failure-domain” spread by placing nodes across **three clusters/datastores** (fd-a/b/c).  
Docs (IPI params for mapping the concept; UPI keeps `platform: none`). :contentReference[oaicite:4]{index=4}
