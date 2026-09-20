#!/usr/bin/env python3
"""Write portable SHA-256 checksums for explicitly allowed release assets."""
import hashlib
from pathlib import Path
import re
import sys

PATTERN = re.compile(
    r"(?:tlp-connector_(?:windows_(?:amd64|386|arm64)(?:\.exe|\.zip)"
    r"|(?:darwin|linux)_(?:amd64|arm64)(?:\.tar\.gz)?)"
    r"|tlp-connector-[0-9][A-Za-z0-9.+_-]*\.(?:msi|pkg|rpm)"
    r"|tlp-connector_[0-9][A-Za-z0-9.+_-]*\.deb"
    r"|BUILDINFO\.json|RELEASE_NOTES\.md)"
)


def assets(root):
    return sorted(p for p in root.iterdir() if p.is_file() and PATTERN.fullmatch(p.name))


if __name__ == "__main__":
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "dist")
    files = assets(root)
    if not files:
        raise SystemExit(f"No release assets in {root}")
    rows = []
    for path in files:
        with path.open("rb") as stream:
            digest = hashlib.file_digest(stream, "sha256").hexdigest()
        rows.append(f"{digest}  {path.name}\n")
        (root / (path.name + ".sha256")).write_text(rows[-1], encoding="utf-8")
    (root / "SHA256SUMS").write_text("".join(rows), encoding="utf-8")
    print(f"Checksummed {len(files)} release assets in {root}")
