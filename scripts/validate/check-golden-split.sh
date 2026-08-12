#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXIT_CODE=0

for version_dir in "$REPO_ROOT"/imageset-configs/*/; do
  version="$(basename "$version_dir")"
  for api_dir in "$version_dir"*/; do
    api="$(basename "$api_dir")"
    golden="$api_dir/golden_all.yaml"
    operators="$api_dir/operators-only.yaml"
    platform_file="$api_dir/platform-only.yaml"
    additional_file="$api_dir/additionalimages-only.yaml"

    [ -f "$golden" ] || continue
    [ -f "$operators" ] || continue

    python3 - "$golden" "$operators" "$version/$api" "$platform_file" "$additional_file" <<'PYEOF' || EXIT_CODE=1
import yaml, sys, os

golden_file = sys.argv[1]
operators_file = sys.argv[2]
label = sys.argv[3]
platform_file = sys.argv[4]
additional_file = sys.argv[5]

with open(golden_file) as f:
    golden = yaml.safe_load(f)

with open(operators_file) as f:
    ops = yaml.safe_load(f)

golden_ops = golden.get("mirror", {}).get("operators", [])
ops_ops = ops.get("mirror", {}).get("operators", [])

def catalog_key(catalog_entry):
    return catalog_entry.get("catalog", "")

def package_set(catalog_entry):
    """Return set of (name, channel, minVersion, maxVersion) tuples for each package."""
    result = set()
    for p in catalog_entry.get("packages", []):
        name = p["name"]
        channels = p.get("channels", [])
        if channels:
            for ch in channels:
                result.add((name, ch.get("name", ""), ch.get("minVersion", ""), ch.get("maxVersion", "")))
        else:
            result.add((name, "", "", ""))
    return result

golden_catalogs = {catalog_key(c): package_set(c) for c in golden_ops}
ops_catalogs = {catalog_key(c): package_set(c) for c in ops_ops}

errors = []
for cat, pkgs in ops_catalogs.items():
    if cat not in golden_catalogs:
        errors.append(f"catalog '{cat}' in operators-only but not golden_all")
    else:
        missing = pkgs - golden_catalogs[cat]
        extra = golden_catalogs[cat] - pkgs
        if missing:
            missing_display = set()
            for n, ch, minv, maxv in missing:
                label = n
                parts = [p for p in [ch, f"min={minv}" if minv else "", f"max={maxv}" if maxv else ""] if p]
                if parts:
                    label += f" ({', '.join(parts)})"
                missing_display.add(label)
            errors.append(f"operators in operators-only but not golden_all for {cat}: {missing_display}")
        if extra:
            extra_display = set()
            for n, ch, minv, maxv in extra:
                label = n
                parts = [p for p in [ch, f"min={minv}" if minv else "", f"max={maxv}" if maxv else ""] if p]
                if parts:
                    label += f" ({', '.join(parts)})"
                extra_display.add(label)
            errors.append(f"operators in golden_all but not operators-only for {cat}: {extra_display}")

# Platform section comparison
if os.path.isfile(platform_file):
    with open(platform_file) as f:
        plat = yaml.safe_load(f)
    golden_platform = golden.get("mirror", {}).get("platform", {})
    plat_platform = plat.get("mirror", {}).get("platform", {})

    golden_channels = golden_platform.get("channels", [])
    plat_channels = plat_platform.get("channels", [])

    def channel_tuples(channels):
        return {(c.get("name", ""), c.get("minVersion", ""), c.get("maxVersion", "")) for c in channels}

    golden_ch_set = channel_tuples(golden_channels)
    plat_ch_set = channel_tuples(plat_channels)
    if golden_ch_set != plat_ch_set:
        errors.append(f"platform channels mismatch: golden_all={golden_ch_set} vs platform-only={plat_ch_set}")

# AdditionalImages comparison
if os.path.isfile(additional_file):
    with open(additional_file) as f:
        addl = yaml.safe_load(f)
    golden_images = golden.get("mirror", {}).get("additionalImages", [])
    addl_images = addl.get("mirror", {}).get("additionalImages", [])

    golden_img_set = {img.get("name", "") for img in golden_images}
    addl_img_set = {img.get("name", "") for img in addl_images}

    if golden_img_set != addl_img_set:
        missing_in_golden = addl_img_set - golden_img_set
        missing_in_addl = golden_img_set - addl_img_set
        if missing_in_golden:
            errors.append(f"images in additionalimages-only but not golden_all: {missing_in_golden}")
        if missing_in_addl:
            errors.append(f"images in golden_all but not additionalimages-only: {missing_in_addl}")

if errors:
    for e in errors:
        print(f"FAIL [{label}]: {e}")
    sys.exit(1)
else:
    print(f"OK [{label}]: split files are consistent with golden_all")
PYEOF
  done
done

exit $EXIT_CODE
