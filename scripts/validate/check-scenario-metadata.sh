#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXIT_CODE=0

while IFS= read -r -d '' scenario_file; do
  dir="$(dirname "$scenario_file")"
  dir_name="$(basename "$dir")"

  python3 - "$scenario_file" "$dir_name" <<'PYEOF' || EXIT_CODE=1
import yaml, sys, os

scenario_file = sys.argv[1]
dir_name = sys.argv[2]
scenario_dir = os.path.dirname(scenario_file)

with open(scenario_file) as f:
    doc = yaml.safe_load(f)

errors = []

name = doc.get("name", "")
if name != dir_name:
    errors.append(f"name '{name}' does not match directory '{dir_name}'")

artifacts = doc.get("artifacts", [])
for a in artifacts:
    if not os.path.isfile(os.path.join(scenario_dir, a)):
        errors.append(f"artifact '{a}' listed but file not found")

if "targetReleases" not in doc:
    errors.append("missing 'targetReleases' field")
else:
    releases = doc["targetReleases"]
    if not releases:
        errors.append("'targetReleases' is empty")
    else:
        import re
        for r in releases:
            if not re.match(r'^\d+\.\d+$', str(r)):
                errors.append(f"invalid targetReleases value '{r}' (expected format: X.Y, e.g. 4.18)")

if "tokens" not in doc:
    errors.append("missing 'tokens' field")

install_config_path = os.path.join(scenario_dir, "install-config.yaml")
if os.path.isfile(install_config_path):
    with open(install_config_path) as f:
        ic = yaml.safe_load(f)
    platform = doc.get("platform", "")
    method = doc.get("method", "")
    ic_platform = ic.get("platform", {})
    # UPI and agent-extlb scenarios legitimately use platform: none in install-config
    # while the scenario.yaml describes the target infrastructure platform
    if "none" in ic_platform and method in ("upi", "agent") and platform in ("baremetal", "aws", "vsphere"):
        pass  # acceptable: UPI/agent-extlb uses platform:none but targets a real platform
    elif "baremetal" in ic_platform:
        if platform not in ("baremetal",):
            errors.append(f"scenario says platform='{platform}' but install-config uses platform.baremetal")
    elif "none" in ic_platform:
        if platform not in ("none",):
            errors.append(f"scenario says platform='{platform}' but install-config uses platform.none")
    elif "aws" in ic_platform:
        if platform not in ("aws",):
            errors.append(f"scenario says platform='{platform}' but install-config uses platform.aws")
    elif "vsphere" in ic_platform:
        if platform not in ("vsphere",):
            errors.append(f"scenario says platform='{platform}' but install-config uses platform.vsphere")

if errors:
    for e in errors:
        print(f"FAIL [{dir_name}]: {e}")
    sys.exit(1)
PYEOF
done < <(find "$REPO_ROOT/installation-configs" "$REPO_ROOT/virtualization-networking-configs" -name 'scenario.yaml' -print0)

if [ $EXIT_CODE -eq 0 ]; then
  echo "All scenario.yaml files pass metadata checks."
fi
exit $EXIT_CODE
