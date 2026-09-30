# \# RAMBO for Bjorn v0.1 - Test Record

# 

# \## Tested Platform

# 

# \- Raspberry Pi Zero 2 W

# \- Raspberry Pi OS Lite 64-bit (Bookworm)

# \- Waveshare 2.13-inch e-paper display

# \- PiSugar 2 (2-LED version)

# \- Upstream Bjorn installed at `/home/bjorn/Bjorn`

# 

# \## v0.1 Validation

# 

# The following tests were completed successfully:

# 

# 1\. Confirmed clean upstream Bjorn installation was running normally.

# 2\. Ran `sudo ./install.sh`.

# 3\. Selected the RAMBO theme.

# 4\. Confirmed installer created safety backups.

# 5\. Confirmed display patch completed successfully.

# 6\. Confirmed Black Ops One font installed and loaded.

# 7\. Confirmed title displays `RAMBO`.

# 8\. Confirmed only one RAMBO character is displayed after a completed e-paper refresh.

# 9\. Confirmed RAMBO status sprites change with Bjorn activity.

# 10\. Confirmed RAMBO dialogue changes normally.

# 11\. Confirmed PiSugar battery telemetry works.

# 12\. Confirmed CPU temperature telemetry works.

# 13\. Confirmed Wi-Fi RSSI telemetry works.

# 14\. Confirmed telemetry format displays correctly:

# 

# &#x20;   `B99  C39  W-44`

# 

# 15\. Confirmed Bjorn service remains active after installation.

# 16\. Ran `sudo bash ./uninstall.sh`.

# 17\. Confirmed original `display.py` was restored.

# 18\. Confirmed original `shared.py` and Bjorn fonts were restored.

# 19\. Confirmed original status sprites were restored.

# 20\. Confirmed original comments/dialogue were restored.

# 21\. Confirmed Bjorn restarted successfully after restoration.

# 22\. Reinstalled RAMBO from a freshly packaged build.

# 23\. Confirmed the clean reinstall reproduced the expected RAMBO interface.

# 

# \## Result

# 

# \*\*PASS - RAMBO for Bjorn v0.1\*\*

# 

# The v0.1 package successfully completed:

# 

# `Stock Bjorn -> RAMBO install -> Stock restore -> RAMBO clean reinstall`

# 

# \## Notes

# 

# E-paper displays can briefly show ghosted content during a refresh. Testing should

# judge the screen after the refresh cycle has completed.

# 

# PiSugar is optional. If PiSugar Server is unavailable, RAMBO should continue

# operating with the battery telemetry field unavailable.

