import sys, pathlib
from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import PreservedScalarString

yaml = YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=2, offset=0)
yaml.width = 1000  # avoid reflowing comments

def ensure_doc_start(text: str) -> str:
    # If the first non-blank, non-comment line is not '---', prepend it.
    lines = text.splitlines()
    i = 0
    while i < len(lines) and (lines[i].strip() == '' or lines[i].lstrip().startswith('#')):
        i += 1
    if i < len(lines):
        if lines[i].strip() != '---':
            return '---\n' + text
    else:
        # empty or only comments => add doc-start
        return '---\n' + text
    return text

def normalize_package(pkg):
    # pkg is a ruamel CommentedMap with at least key 'name'.
    # Ensure exactly one 'channels' list with items that only contain 'name'.
    ch = pkg.get('channels', None)
    if ch is None:
        # Insert stub
        pkg['channels'] = [{'name': 'CHANGE_ME'}]
        return

    # If channels exists, make sure it is a proper sequence of maps with 'name' only.
    if not isinstance(ch, list):
        # Unexpected type: replace with stub
        pkg['channels'] = [{'name': 'CHANGE_ME'}]
        return

    cleaned = []
    names_seen = set()
    for item in ch:
        if isinstance(item, dict):
            # prefer explicit name if present
            nm = item.get('name', None)
            if nm is None:
                # try to flatten nested channels incorrectly injected earlier
                # if item has 'channels' key inside, ignore it; keep nothing if no name
                pass
            else:
                if nm not in names_seen:
                    cleaned.append({'name': nm})
                    names_seen.add(nm)
        elif isinstance(item, str):
            # If a bare string slipped in, treat it as a name
            if item not in names_seen:
                cleaned.append({'name': item})
                names_seen.add(item)
        else:
            # Unknown form; skip
            pass

    if not cleaned:
        cleaned = [{'name': 'CHANGE_ME'}]

    pkg['channels'] = cleaned

def process_file(path: pathlib.Path):
    original = path.read_text(encoding='utf-8')
    text = ensure_doc_start(original)
    from io import StringIO
    buf = StringIO(text)
    data = yaml.load(buf)

    # Some imagesets are v1 (mirror.openshift.io/v1alpha2), some v2 (mirror.openshift.io/v2alpha1).
    # Path to packages: data['mirror']['operators'][i]['packages']
    try:
        mirror = data.get('mirror', None)
        if isinstance(mirror, dict):
            ops = mirror.get('operators', None)
            if isinstance(ops, list):
                for cat in ops:
                    if not isinstance(cat, dict):
                        continue
                    pkgs = cat.get('packages', None)
                    if isinstance(pkgs, list):
                        for pkg in pkgs:
                            if isinstance(pkg, dict) and 'name' in pkg:
                                normalize_package(pkg)
        # write back
        out = pathlib.Path(path)
        with out.open('w', encoding='utf-8') as fh:
            yaml.dump(data, fh)
    except Exception as e:
        # If parsing fails, restore original content
        out = pathlib.Path(path)
        out.write_text(original, encoding='utf-8')
        print(f"[WARN] Skipped (parse error): {path} -> {e}", file=sys.stderr)

def main():
    root = pathlib.Path('.')
    files = list(root.glob('imagesets/**/*.yaml'))
    if not files:
        print("[info] No imageset files found.")
    for f in files:
        process_file(f)

    # Replace ${scen} placeholders in scenario READMEs with the directory name
    for readme in root.glob('installation-configs/baremetal/agent/**/README.md'):
        try:
            txt = readme.read_text(encoding='utf-8')
            if '${scen}' in txt:
                scen = readme.parent.name
                txt = txt.replace('${scen}', scen)
                readme.write_text(txt, encoding='utf-8')
        except Exception as e:
            print(f"[WARN] README update failed {readme}: {e}", file=sys.stderr)

if __name__ == '__main__':
    main()
