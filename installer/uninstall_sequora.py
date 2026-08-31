#!/usr/bin/env python3
import os
import shutil
import winreg
from pathlib import Path

APP_NAME = "SEQUORA Studio"
user_profile = Path(os.environ.get("USERPROFILE", "C:\Users\Default"))
desktop_candidates = [
    user_profile / "Desktop" / f"{APP_NAME}.lnk",
    user_profile / "OneDrive" / "Desktop" / f"{APP_NAME}.lnk"
]
start_menu_dir = Path(os.environ.get("APPDATA", "")) / "Microsoft" / "Windows" / "Start Menu" / "Programs" / "SEQUORA Studio"

# Remove shortcuts
for dt in desktop_candidates:
    if dt.exists():
        try:
            dt.unlink()
        except Exception:
            pass

if start_menu_dir.exists():
    try:
        shutil.rmtree(start_menu_dir, ignore_errors=True)
    except Exception:
        pass

# Remove registry
try:
    winreg.DeleteKey(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Uninstall\SEQUORA_Studio")
except Exception:
    pass

print(f"[OK] {APP_NAME} has been successfully uninstalled from Windows.")
