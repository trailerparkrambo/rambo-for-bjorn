#!/usr/bin/env bash
set -Eeuo pipefail

BJORN_DIR="${BJORN_DIR:-/home/bjorn/Bjorn}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
ENGINE_DIR="$SCRIPT_DIR/engine"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[[ $EUID -eq 0 ]] || die "Run this installer with sudo."
[[ -d "$BJORN_DIR" ]] || die "Bjorn not found at $BJORN_DIR."
[[ -f "$BJORN_DIR/display.py" ]] || die "Bjorn display.py not found."
[[ -f "$BJORN_DIR/shared.py" ]] || die "Bjorn shared.py not found."
[[ -d "$BJORN_DIR/resources/images/status" ]] || die "Bjorn status images not found."
[[ -f "$BJORN_DIR/resources/comments/comments.json" ]] || die "Bjorn comments.json not found."
[[ -d "$THEMES_DIR" ]] || die "Themes directory not found."
[[ -f "$ENGINE_DIR/display_patch.py" ]] || die "Display patch engine not found."
[[ -f "$ENGINE_DIR/comments_patch.py" ]] || die "Comments patch engine not found."

echo
echo "======================================"
echo "          BJORN THEME ENGINE"
echo "======================================"
echo

themes=()
for theme_dir in "$THEMES_DIR"/*/; do
    [[ -d "$theme_dir" ]] || continue
    [[ -f "$theme_dir/theme.json" ]] || continue
    themes+=("$(basename "$theme_dir")")
done

[[ ${#themes[@]} -gt 0 ]] || die "No themes were found."

echo "Available themes:"
echo

for i in "${!themes[@]}"; do
    printf "  [%d] %s\n" "$((i + 1))" "${themes[$i]}"
done

echo
read -rp "Choose a theme: " choice

[[ "$choice" =~ ^[0-9]+$ ]] || die "Invalid selection."
(( choice >= 1 && choice <= ${#themes[@]} )) || die "Invalid selection."

THEME_ID="${themes[$((choice - 1))]}"
THEME_DIR="$THEMES_DIR/$THEME_ID"
THEME_FILE="$THEME_DIR/theme.json"
THEME_COMMENTS="$THEME_DIR/comments.json"
SPRITES_DIR="$THEME_DIR/sprites"

echo
echo "Selected theme: $THEME_ID"
echo

BACKUP_DIR="$BJORN_DIR/backup/bjorn-theme-engine"

rollback() {
    echo
    echo "Install failed. Rolling Bjorn back..."

    if [[ -f "$BACKUP_DIR/display.py" ]]; then
        cp -f "$BACKUP_DIR/display.py" "$BJORN_DIR/display.py"
    fi

    if [[ -f "$BACKUP_DIR/shared.py" ]]; then
        cp -f "$BACKUP_DIR/shared.py" "$BJORN_DIR/shared.py"
    fi

    if [[ -d "$BACKUP_DIR/status" ]]; then
        rm -rf "$BJORN_DIR/resources/images/status"
        cp -a "$BACKUP_DIR/status" "$BJORN_DIR/resources/images/status"
    fi

    if [[ -f "$BACKUP_DIR/comments.json" ]]; then
        cp -f \
            "$BACKUP_DIR/comments.json" \
            "$BJORN_DIR/resources/comments/comments.json"
    fi

    systemctl restart bjorn 2>/dev/null || true

    echo "Rollback complete."
}

trap rollback ERR

echo "Creating safety backup..."
mkdir -p "$BACKUP_DIR"

if [[ ! -f "$BACKUP_DIR/display.py" ]]; then
    cp -a "$BJORN_DIR/display.py" "$BACKUP_DIR/display.py"
fi

if [[ ! -f "$BACKUP_DIR/shared.py" ]]; then
    cp -a "$BJORN_DIR/shared.py" "$BACKUP_DIR/shared.py"
fi

if [[ ! -d "$BACKUP_DIR/status" ]]; then
    cp -a \
        "$BJORN_DIR/resources/images/status" \
        "$BACKUP_DIR/status"
fi

if [[ ! -f "$BACKUP_DIR/comments.json" ]]; then
    cp -a \
        "$BJORN_DIR/resources/comments/comments.json" \
        "$BACKUP_DIR/comments.json"
fi

echo "Backup ready."

echo
echo "Stopping Bjorn..."
systemctl stop bjorn

echo "Applying display theme..."
python3 \
    "$ENGINE_DIR/display_patch.py" \
    "$BJORN_DIR" \
    "$THEME_FILE"

if [[ -f "$THEME_COMMENTS" ]]; then
    echo "Installing theme dialogue..."

    python3 \
        "$ENGINE_DIR/comments_patch.py" \
        "$BJORN_DIR" \
        "$THEME_COMMENTS"
fi

if [[ -d "$SPRITES_DIR" ]]; then
    echo "Installing theme sprites..."

    for sprite_dir in "$SPRITES_DIR"/*/; do
        [[ -d "$sprite_dir" ]] || continue

        name="$(basename "$sprite_dir")"
        src="$sprite_dir/$name.bmp"
        dst="$BJORN_DIR/resources/images/status/$name"

        [[ -f "$src" ]] || die "Missing sprite: $src"
        [[ -d "$dst" ]] || die "Bjorn status folder missing: $name"

        found=0

        while IFS= read -r -d '' file; do
            cp -f "$src" "$file"
            found=1
        done < <(
            find "$dst" \
                -maxdepth 1 \
                -type f \
                -name '*.bmp' \
                -print0
        )

        [[ $found -eq 1 ]] || die "No BMP targets found for: $name"
    done
fi

echo "Checking modified Bjorn code..."

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
    || die "Bjorn failed to stay running after theme installation."

trap - ERR

echo
echo "======================================"
echo "       THEME INSTALLED SUCCESSFULLY"
echo "======================================"
echo
echo "Theme: $THEME_ID"
echo
echo "HUD:"
echo "  B = PiSugar battery"
echo "  C = CPU temperature"
echo "  W = Wi-Fi RSSI"
echo
echo "Reboot recommended:"
echo "  sudo reboot"
echo