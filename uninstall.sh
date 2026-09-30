#!/usr/bin/env bash
set -Eeuo pipefail

BJORN_DIR="${BJORN_DIR:-/home/bjorn/Bjorn}"
BACKUP_DIR="$BJORN_DIR/backup/bjorn-theme-engine"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[[ $EUID -eq 0 ]] || die "Run this uninstaller with sudo."
[[ -d "$BJORN_DIR" ]] || die "Bjorn not found at $BJORN_DIR."
[[ -f "$BACKUP_DIR/display.py" ]] || die "Original display backup not found."
[[ -f "$BACKUP_DIR/shared.py" ]] || die "Original shared.py backup not found."
[[ -d "$BACKUP_DIR/status" ]] || die "Original sprite backup not found."
[[ -f "$BACKUP_DIR/comments.json" ]] || die "Original comments backup not found."

echo
echo "======================================"
echo "       BJORN THEME ENGINE RESTORE"
echo "======================================"
echo

echo "Stopping Bjorn..."
systemctl stop bjorn 2>/dev/null || true

echo "Restoring original display..."
cp -f "$BACKUP_DIR/display.py" "$BJORN_DIR/display.py"

echo "Restoring original fonts and shared settings..."
cp -f "$BACKUP_DIR/shared.py" "$BJORN_DIR/shared.py"

echo "Restoring original sprites..."
rm -rf "$BJORN_DIR/resources/images/status"
cp -a "$BACKUP_DIR/status" "$BJORN_DIR/resources/images/status"

echo "Restoring original dialogue..."
cp -f \
    "$BACKUP_DIR/comments.json" \
    "$BJORN_DIR/resources/comments/comments.json"

echo "Validating restored files..."
python3 -m py_compile \
    "$BJORN_DIR/display.py" \
    "$BJORN_DIR/shared.py"

python3 -m json.tool \
    "$BJORN_DIR/resources/comments/comments.json" \
    >/dev/null

echo "Starting Bjorn..."
systemctl restart bjorn

sleep 3

systemctl is-active --quiet bjorn \
    || die "Bjorn did not start after restoration."

echo
echo "======================================"
echo "        ORIGINAL BJORN RESTORED"
echo "======================================"
echo
echo "Display, fonts, sprites, and dialogue restored."
echo "The clean backup has been preserved."
echo