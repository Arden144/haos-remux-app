#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

version="${1:-}"
if [[ -z "$version" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is required when no version argument is provided" >&2
    exit 1
  fi

  tag="$(gh api repos/lostb1t/remux/releases/latest --jq '.tag_name')"
  version="${tag#v}"
else
  version="${version#v}"
fi

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Invalid Remux version: $version" >&2
  exit 1
fi

python3 - "$version" <<'PY'
from pathlib import Path
import sys

version = sys.argv[1]
root = Path.cwd()

config = root / "remux/config.yaml"
dockerfile = root / "remux/Dockerfile"
changelog = root / "remux/CHANGELOG.md"
docs = root / "remux/DOCS.md"

config_text = config.read_text()
lines = config_text.splitlines(keepends=True)
for index, line in enumerate(lines):
    if line.startswith("version:"):
        lines[index] = f'version: "{version}"\n'
        break
else:
    raise SystemExit("Could not find version in remux/config.yaml")
config.write_text("".join(lines))

dockerfile.write_text(
    f"FROM ghcr.io/lostb1t/remux:{version}\n"
)

changelog_text = changelog.read_text()
heading = f"## {version}"
if heading not in changelog_text:
    marker = "# Changelog\n\n"
    if not changelog_text.startswith(marker):
        raise SystemExit("Unexpected remux/CHANGELOG.md heading")
    changelog_text = (
        marker
        + f"{heading}\n\n"
        + f"- Update Remux to [v{version}](https://github.com/lostb1t/remux/releases/tag/v{version}).\n\n"
        + changelog_text[len(marker):]
    )
    changelog.write_text(changelog_text)

docs_text = docs.read_text()
for old_version in __import__("re").findall(r"App version `([^`]+)` uses Remux `[^`]+`", docs_text):
    docs_text = docs_text.replace(
        f"App version `{old_version}` uses Remux `{old_version}`.",
        f"App version `{version}` uses Remux `{version}`.",
    )
docs_text = __import__("re").sub(
    r"(pins `ghcr\.io/lostb1t/remux:)[^`]+(`)",
    rf"\g<1>{version}\g<2>",
    docs_text,
)
docs.write_text(docs_text)
PY

echo "Bumped Remux app to $version"
