# vSphere — UPI — Proxied — HA — Single Failure Domain

Same as connected UPI but with a **cluster-wide proxy**.  
Provide proxy URLs and a strong `noProxy` (cluster domains + RFC1918 + your CIDR).  
Create external LBs and DNS (`api`, `api-int`, `*.apps`) yourself.  
Docs (UPI flow; proxy with additionalTrustBundle). :contentReference[oaicite:5]{index=5}
