# \# RAMBO for Bjorn

# 

# > \*\*They drew first ping.\*\*

# 

# RAMBO for Bjorn is a custom visual theme and HUD extension for the

# \[Bjorn](https://github.com/infinition/Bjorn) Raspberry Pi e-paper project.

# 

# It transforms Bjorn into a RAMBO-themed interface with custom status sprites,

# dialogue, typography, and live system telemetry while preserving Bjorn's

# underlying functionality.

# 

# \## v0.1

# 

# RAMBO v0.1 has been tested through a complete install, uninstall/restore, and

# clean reinstall cycle.

# 

# \### Features

# 

# \- Custom RAMBO title and interface

# \- 17 custom RAMBO activity/status sprites

# \- RAMBO-themed dialogue

# \- Black Ops One military-style typography

# \- Live PiSugar battery telemetry

# \- Live CPU temperature telemetry

# \- Live Wi-Fi RSSI telemetry

# \- Automatic backup of original Bjorn files

# \- Automatic rollback if installation fails

# \- Full uninstall and restoration of original Bjorn

# \- Theme configuration through `theme.json`

# 

# The telemetry bar uses the compact format:

# 

# ```text

# B99  C39  W-44

# ```

# 

# Where:

# 

# \- `B` = PiSugar battery percentage

# \- `C` = CPU temperature in Celsius

# \- `W` = Wi-Fi RSSI in dBm

# 

# If PiSugar telemetry is unavailable, the battery field displays `--`.

# 

# \## Tested Hardware

# 

# RAMBO v0.1 was developed and tested with:

# 

# \- Raspberry Pi Zero 2 W

# \- Raspberry Pi OS Lite 64-bit (Bookworm)

# \- Waveshare 2.13-inch e-paper display

# \- PiSugar 2 (2-LED version)

# \- Bjorn installed at `/home/bjorn/Bjorn`

# 

# Other hardware supported by Bjorn may work but has not yet been tested with

# RAMBO.

# 

# \## Requirements

# 

# Install and verify upstream Bjorn before installing RAMBO.

# 

# Upstream project:

# 

# https://github.com/infinition/Bjorn

# 

# For battery telemetry, PiSugar Server should be running and accessible on:

# 

# ```text

# 127.0.0.1:8423

# ```

# 

# PiSugar is optional. RAMBO continues to operate if battery telemetry is not

# available.

# 

# \## Installation

# 

# Clone or download this repository onto the Raspberry Pi.

# 

# Enter the project directory:

# 

# ```bash

# cd rambo-for-bjorn

# ```

# 

# Make the installer executable if necessary:

# 

# ```bash

# chmod +x install.sh

# ```

# 

# Run:

# 

# ```bash

# sudo ./install.sh

# ```

# 

# Choose:

# 

# ```text

# \[1] rambo

# ```

# 

# The installer will:

# 

# 1\. Create a safety backup of the original Bjorn files.

# 2\. Stop the Bjorn service.

# 3\. Install the theme font.

# 4\. Patch the display and telemetry HUD.

# 5\. Install RAMBO dialogue.

# 6\. Install RAMBO status sprites.

# 7\. Validate the modified Python and JSON files.

# 8\. Restart Bjorn.

# 9\. Roll back automatically if installation fails.

# 

# \## Uninstall / Restore Original Bjorn

# 

# Run:

# 

# ```bash

# sudo bash ./uninstall.sh

# ```

# 

# The uninstaller restores the original:

# 

# \- `display.py`

# \- `shared.py`

# \- status sprites

# \- comments/dialogue

# 

# It then validates the restored files and restarts Bjorn.

# 

# The clean backup is preserved so it can be reused later.

# 

# \## Theme Structure

# 

# ```text

# rambo-for-bjorn/

# ├── engine/

# │   ├── comments\_patch.py

# │   └── display\_patch.py

# ├── themes/

# │   └── rambo/

# │       ├── comments.json

# │       ├── theme.json

# │       ├── fonts/

# │       │   └── BlackOpsOne-Regular.ttf

# │       └── sprites/

# ├── docs/

# ├── install.sh

# ├── uninstall.sh

# ├── LICENSE

# └── README.md

# ```

# 

# \## Black Ops One

# 

# RAMBO uses \*\*Black Ops One\*\* for its military-style interface typography.

# 

# Black Ops One is distributed under the SIL Open Font License and is available

# through the Google Fonts project.

# 

# \## Upstream Bjorn

# 

# RAMBO for Bjorn is an independent community add-on and is not an official

# Bjorn release.

# 

# Bjorn is developed by \*\*infinition\*\*:

# 

# https://github.com/infinition/Bjorn

# 

# RAMBO does not replace Bjorn. It modifies selected display resources and

# interface files while preserving a backup of the originals.

# 

# \## Roadmap

# 

# Future versions may include:

# 

# \- Watch Your Six nearby-device awareness display

# \- Additional themes

# \- Additional telemetry options

# \- Improved theme-engine configuration

# \- Additional e-paper display compatibility

# \- Easier installation and release packaging

# 

# \## Version

# 

# \*\*RAMBO for Bjorn v0.1\*\*

# 

# First tested release.

# 

# > \*\*Nothing is over!\*\*

# 

# \## License

# 

# The RAMBO theme engine and installer code are released under the MIT License.

# 

# Black Ops One is distributed separately under the SIL Open Font License.

# 

# Third-party projects, trademarks, characters, artwork, and other assets remain

# subject to their respective owners and licenses.

