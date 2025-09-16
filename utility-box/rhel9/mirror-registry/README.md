# Local mirror registry (lab-grade)

Steps outline:
1. Create a self-signed registry certificate and key.
2. Run a local registry with podman.
3. Add the registry CA to your `additionalTrustBundle` (agent installs) or to cluster trust later.

Example:
```bash
mkdir -p /etc/pki/registry
openssl req -x509 -newkey rsa:4096 -days 365 -nodes -subj "/CN=registry.example.local" \
  -keyout /etc/pki/registry/tls.key -out /etc/pki/registry/tls.crt

# Run registry
podman run -d --name mirror-registry --restart=always -p 5000:5000 \
  -v /var/lib/registry:/var/lib/registry:z \
  -v /etc/pki/registry:/certs:z \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/tls.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/tls.key \
  registry:2
```

Add the CA to your installer inputs by concatenating the proxy CA (if any) followed by this registry CA into a single PEM in `additionalTrustBundle`, and set `additionalTrustBundlePolicy: Always`.
