#!/usr/bin/env python3

from pathlib import Path
import json
import sys


def die(message):
    raise SystemExit(f"ERROR: {message}")


if len(sys.argv) < 3:
    die("Usage: comments_patch.py BJORN_DIR THEME_COMMENTS")

bjorn_dir = Path(sys.argv[1])
theme_file = Path(sys.argv[2])

bjorn_comments = (
    bjorn_dir / "resources" / "comments" / "comments.json"
)

if not bjorn_comments.exists():
    die(f"Bjorn comments file not found: {bjorn_comments}")

if not theme_file.exists():
    die(f"Theme comments file not found: {theme_file}")

try:
    original = json.loads(
        bjorn_comments.read_text(encoding="utf-8")
    )

    themed = json.loads(
        theme_file.read_text(encoding="utf-8")
    )
except Exception as exc:
    die(f"Could not read comments JSON: {exc}")

if not isinstance(original, dict):
    die("Bjorn comments.json is not a JSON object.")

if not isinstance(themed, dict):
    die("Theme comments.json is not a JSON object.")

for category, comments in themed.items():
    if not isinstance(comments, list):
        die(f'Theme category "{category}" must contain a list.')

    original[category] = comments

bjorn_comments.write_text(
    json.dumps(original, indent=4, ensure_ascii=False) + "\n",
    encoding="utf-8"
)

print(
    f"Merged {len(themed)} theme comment "
    f"category/categories into Bjorn."
)