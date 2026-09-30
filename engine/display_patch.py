#!/usr/bin/env python3

from pathlib import Path
import json
import shutil
import sys


def die(message):
    raise SystemExit(f"ERROR: {message}")


# Usage:
#   python3 display_patch.py /home/bjorn/Bjorn /path/to/theme.json

bjorn = Path(
    sys.argv[1] if len(sys.argv) > 1 else "/home/bjorn/Bjorn"
)

if len(sys.argv) < 3:
    die("No theme.json supplied.")

theme_file = Path(sys.argv[2])

if not theme_file.exists():
    die(f"Theme file not found: {theme_file}")

try:
    theme = json.loads(
        theme_file.read_text(encoding="utf-8")
    )
except Exception as exc:
    die(f"Could not read theme.json: {exc}")


# ------------------------------------------------------------
# THEME SETTINGS
# ------------------------------------------------------------

title = str(theme.get("title", "BJORN")).strip()

if not title:
    die("Theme title cannot be empty.")

hud = theme.get("hud", {})
hud_enabled = bool(hud.get("enabled", False))

font = theme.get("font", {})
font_file = font.get("file")

display = bjorn / "display.py"
shared = bjorn / "shared.py"

if not display.exists():
    die(f"{display} not found.")

if not shared.exists():
    die(f"{shared} not found.")


# ------------------------------------------------------------
# INSTALL THEME FONT
# ------------------------------------------------------------

if font_file:
    source_font = theme_file.parent / font_file

    if not source_font.exists():
        die(f"Theme font not found: {source_font}")

    font_dir = bjorn / "resources" / "fonts"

    if not font_dir.exists():
        die(f"Bjorn font directory not found: {font_dir}")

    installed_font = font_dir / source_font.name

    shutil.copy2(source_font, installed_font)

    font_name = installed_font.name

    shared_text = shared.read_text(encoding="utf-8")
    shared_original = shared_text

    replacements = {
        "self.font_arial14 = self.load_font('Arial.ttf', 14)":
            (
                "self.font_arial14 = "
                f"self.load_font('{font_name}', "
                f"{int(font.get('large_size', 14))})"
            ),

        "self.font_arial11 = self.load_font('Arial.ttf', 11)":
            (
                "self.font_arial11 = "
                f"self.load_font('{font_name}', "
                f"{int(font.get('medium_size', 11))})"
            ),

        "self.font_arial9 = self.load_font('Arial.ttf', 9)":
            (
                "self.font_arial9 = "
                f"self.load_font('{font_name}', "
                f"{int(font.get('small_size', 9))})"
            ),

        "self.font_arialbold = self.load_font('Arial.ttf', 12)":
            (
                "self.font_arialbold = "
                f"self.load_font('{font_name}', "
                f"{int(font.get('bold_size', 12))})"
            ),

        "self.font_viking = self.load_font('Viking.TTF', 13)":
            (
                "self.font_viking = "
                f"self.load_font('{font_name}', "
                f"{int(font.get('title_size', 13))})"
            )
    }

    for old, new in replacements.items():
        if old in shared_text:
            shared_text = shared_text.replace(old, new, 1)
        elif new not in shared_text:
            die(
                "Expected Bjorn font definition not found: "
                + old
            )

    if shared_text != shared_original:
        shared.write_text(
            shared_text,
            encoding="utf-8"
        )

        print(
            f'Theme font "{font_name}" installed.'
        )


# ------------------------------------------------------------
# DISPLAY PATCH
# ------------------------------------------------------------

text = display.read_text(encoding="utf-8")
original = text


# ------------------------------------------------------------
# TITLE
# ------------------------------------------------------------

title_anchor = (
    'draw.text((int(37 * self.scale_factor_x), '
    'int(5 * self.scale_factor_y)), "BJORN", '
    'font=self.shared_data.font_viking, fill=0)'
)

themed_title = (
    'draw.text((int(37 * self.scale_factor_x), '
    f'int(5 * self.scale_factor_y)), "{title}", '
    'font=self.shared_data.font_viking, fill=0)'
)

if title_anchor in text:
    text = text.replace(
        title_anchor,
        themed_title,
        1
    )
elif themed_title not in text:
    die(
        "Bjorn title anchor not found. "
        "Refusing to patch unknown display.py."
    )


# ------------------------------------------------------------
# REMOVE UPPER DUPLICATE STATUS CHARACTER
# ------------------------------------------------------------

status_start = (
    "                "
    "self.shared_data.update_bjornstatus()"
)

hud_marker = (
    "                # Theme Engine HUD"
)

if status_start in text:
    start = text.index(status_start)

    if hud_marker in text[start:]:
        end = text.index(hud_marker, start)
        text = text[:start] + text[end:]


# ------------------------------------------------------------
# OPTIONAL TELEMETRY HUD
# ------------------------------------------------------------

if hud_enabled:

    run_marker = "    def run(self):\n"

    telemetry_method = '''    def get_theme_telemetry(self):
        """Return compact battery / CPU / Wi-Fi telemetry."""
        battery = "--"
        temp = "--"
        wifi = "--"

        try:
            import socket
            with socket.create_connection(
                ("127.0.0.1", 8423), timeout=0.35
            ) as sock:
                sock.sendall(b"get battery\\n")
                raw = sock.recv(128).decode(
                    "utf-8", "ignore"
                ).strip()

            if ":" in raw:
                battery = str(
                    round(
                        float(
                            raw.split(":")[-1].strip()
                        )
                    )
                )
        except Exception:
            pass

        try:
            raw = subprocess.check_output(
                ["vcgencmd", "measure_temp"],
                text=True,
                timeout=0.5
            ).strip()

            temp = str(
                round(
                    float(
                        raw.split("=")[-1]
                        .replace("'C", "")
                    )
                )
            )
        except Exception:
            pass

        try:
            raw = subprocess.check_output(
                ["iw", "dev", "wlan0", "link"],
                text=True,
                timeout=0.5
            )

            for line in raw.splitlines():
                if "signal:" in line:
                    wifi = (
                        line.split("signal:", 1)[1]
                        .strip()
                        .split()[0]
                    )
                    break
        except Exception:
            pass

        return f"B{battery}  C{temp}  W{wifi}"

'''

    if "def get_theme_telemetry(self):" not in text:
        if run_marker not in text:
            die(
                "Display.run() anchor not found. "
                "No changes written."
            )

        text = text.replace(
            run_marker,
            telemetry_method + run_marker,
            1
        )

    old_frise = '''                # Get frise position based on display type
                frise_x, frise_y = self.get_frise_position()
                image.paste(self.shared_data.frise, (frise_x, frise_y))
'''

    new_hud = '''                # Theme Engine HUD
                draw.text(
                    (4, 69),
                    self.get_theme_telemetry(),
                    font=self.shared_data.font_arial9,
                    fill=0
                )
'''

    if old_frise in text:
        text = text.replace(
            old_frise,
            new_hud,
            1
        )

    elif "self.get_theme_telemetry()" not in text:
        die(
            "Frise render anchor not found. "
            "No changes written."
        )


# ------------------------------------------------------------
# WRITE DISPLAY
# ------------------------------------------------------------

if text != original:
    display.write_text(
        text,
        encoding="utf-8"
    )


print(
    f'Theme "{theme.get("name", title)}" '
    "display patch applied."
)