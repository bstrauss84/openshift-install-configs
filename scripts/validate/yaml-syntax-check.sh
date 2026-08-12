#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXIT_CODE=0
COUNT=0
FAIL=0

while IFS= read -r -d '' f; do
  COUNT=$((COUNT + 1))
  result=$(python3 - "$f" <<'PYEOF'
import yaml, sys

class DuplicateKeyError(Exception):
    pass

class UniqueKeyLoader(yaml.SafeLoader):
    pass

def construct_mapping(loader, node, deep=False):
    loader.flatten_mapping(node)
    pairs = loader.construct_pairs(node, deep=deep)
    keys = set()
    for key, value in pairs:
        if key in keys:
            raise DuplicateKeyError(f"Duplicate key: {key}")
        keys.add(key)
    return dict(pairs)

UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_mapping
)

filepath = sys.argv[1]
try:
    with open(filepath) as fh:
        list(yaml.load_all(fh, Loader=UniqueKeyLoader))
except DuplicateKeyError as e:
    print(f"DUPLICATE_KEY: {e}")
    sys.exit(1)
except yaml.YAMLError as e:
    print(f"YAML_ERROR: {e}")
    sys.exit(1)
PYEOF
  )
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "FAIL: $f"
    if [ -n "$result" ]; then
      echo "  $result"
    fi
    FAIL=$((FAIL + 1))
    EXIT_CODE=1
  fi
done < <(find "$REPO_ROOT" -name '*.yaml' -not -path '*/.git/*' -print0)

echo ""
echo "Checked $COUNT YAML files: $((COUNT - FAIL)) passed, $FAIL failed."
exit $EXIT_CODE
