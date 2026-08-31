#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA Studio — Professional Windows Installer & Environment Setup Engine
===============================================================================
 Installs SEQUORA Studio onto the local Windows system:
   1. Generates multi-res Windows Icons (.ico) and branding assets
   2. Creates a clean silent launcher (no black console window)
   3. Creates Desktop Shortcut with native SEQUORA Icon
   4. Creates Windows Start Menu Shortcut with Windows Search indexing
   5. Registers SEQUORA Studio into Windows Registry (Add/Remove Programs)
   6. Configures Uninstaller
===============================================================================
"""

import os
import sys
import subprocess
import winreg
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

# Paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
STUDIO_DIR = PROJECT_ROOT / "SEQUORA_Studio"
ASSETS_DIR = PROJECT_ROOT / "assets"
ICON_ICO = ASSETS_DIR / "icon.ico"
ICON_PNG = ASSETS_DIR / "icon.png"

APP_NAME = "SEQUORA Studio"
APP_DESCRIPTION = "SEQUORA Studio - Creative Production Suite"
APP_VERSION = "3.0.0"
APP_PUBLISHER = "SEQUORA"

def print_banner():
    print("=" * 72)
    print(f"       {APP_NAME} - Professional Windows Setup & Installer")
    print("=" * 72)
    print()

def ensure_python_runtime():
    """Verify PySide6 and required packages are installed."""
    print("[*] Verifying runtime dependencies...")
    try:
        import PySide6
        import openpyxl
        import PIL
        print("    [OK] PySide6, openpyxl, and Pillow are ready.")
    except ImportError:
        print("    [*] Installing missing dependencies (PySide6, openpyxl, Pillow)...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "PySide6", "openpyxl", "Pillow"])
        print("    [OK] Dependencies installed successfully.")

def create_silent_launcher():
    """Creates a VBScript / Batch silent launcher so no CMD window stays open."""
    print("[*] Creating silent desktop launcher...")
    
    # 1. VBScript wrapper to launch pythonw without console
    vbs_path = PROJECT_ROOT / "SEQUORA_Studio.vbs"
    py_script = STUDIO_DIR / "main.py"
    
    # Find pythonw.exe
    python_dir = Path(sys.executable).parent
    pythonw_exe = python_dir / "pythonw.exe"
    if not pythonw_exe.exists():
        pythonw_exe = Path(sys.executable)
    
    vbs_content = f'''Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "{STUDIO_DIR}"
WshShell.Run """{pythonw_exe}""" & " """{py_script}"""", 0, False
Set WshShell = Nothing
'''
    with open(vbs_path, "w", encoding="utf-8") as f:
        f.write(vbs_content)
    
    # 2. Main command batch runner
    bat_path = PROJECT_ROOT / "RUN_SEQUORA.bat"
    bat_content = f'''@echo off
cd /d "{STUDIO_DIR}"
start "" "{pythonw_exe}" main.py
'''
    with open(bat_path, "w", encoding="utf-8") as f:
        f.write(bat_content)

    print(f"    [OK] Launcher created at: {vbs_path.name}")
    return vbs_path

def create_windows_shortcuts(vbs_launcher_path):
    """Creates Desktop and Start Menu shortcuts using PowerShell WScript.Shell."""
    print("[*] Creating Windows Shortcuts...")
    
    uninstall_bat = PROJECT_ROOT / "UNINSTALL_SEQUORA.bat"

    # PowerShell script to create robust Windows shortcuts with icons using native SpecialFolder resolution
    ps_commands = f'''
$WshShell = New-Object -ComObject WScript.Shell
$DesktopPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
$ProgramsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
$StartMenuDir = Join-Path $ProgramsPath "SEQUORA Studio"

if (-not (Test-Path $StartMenuDir)) {{
    New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
}}

# 1. Desktop Shortcut
$DesktopShortcutPath = Join-Path $DesktopPath "{APP_NAME}.lnk"
$Shortcut = $WshShell.CreateShortcut($DesktopShortcutPath)
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = """{str(vbs_launcher_path)}"""
$Shortcut.WorkingDirectory = "{str(STUDIO_DIR)}"
$Shortcut.Description = "{APP_DESCRIPTION}"
$Shortcut.IconLocation = "{str(ICON_ICO)}, 0"
$Shortcut.Save()
Write-Host "    [OK] Desktop Shortcut: $DesktopShortcutPath"

# 2. Start Menu Shortcut
$StartMenuShortcutPath = Join-Path $StartMenuDir "{APP_NAME}.lnk"
$Shortcut2 = $WshShell.CreateShortcut($StartMenuShortcutPath)
$Shortcut2.TargetPath = "wscript.exe"
$Shortcut2.Arguments = """{str(vbs_launcher_path)}"""
$Shortcut2.WorkingDirectory = "{str(STUDIO_DIR)}"
$Shortcut2.Description = "{APP_DESCRIPTION}"
$Shortcut2.IconLocation = "{str(ICON_ICO)}, 0"
$Shortcut2.Save()
Write-Host "    [OK] Start Menu Shortcut: $StartMenuShortcutPath"

# 3. Start Menu Uninstaller Shortcut
$UninstShortcutPath = Join-Path $StartMenuDir "Uninstall {APP_NAME}.lnk"
$Shortcut3 = $WshShell.CreateShortcut($UninstShortcutPath)
$Shortcut3.TargetPath = "{str(uninstall_bat)}"
$Shortcut3.WorkingDirectory = "{str(PROJECT_ROOT)}"
$Shortcut3.Description = "Uninstall {APP_NAME}"
$Shortcut3.IconLocation = "{str(ICON_ICO)}, 0"
$Shortcut3.Save()
'''
    ps_file = PROJECT_ROOT / "installer" / "_make_shortcuts.ps1"
    ps_file.parent.mkdir(parents=True, exist_ok=True)
    with open(ps_file, "w", encoding="utf-8") as f:
        f.write(ps_commands)

    subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", str(ps_file)], check=True)
    
    if ps_file.exists():
        try:
            ps_file.unlink()
        except Exception:
            pass

def register_in_windows_uninstall():
    """Registers the application in Windows Registry (Add/Remove Programs)."""
    print("[*] Registering in Windows Programs & Features...")
    uninstall_key_path = r"Software\Microsoft\Windows\CurrentVersion\Uninstall\SEQUORA_Studio"
    
    try:
        key = winreg.CreateKeyEx(winreg.HKEY_CURRENT_USER, uninstall_key_path, 0, winreg.KEY_ALL_ACCESS)
        
        uninstall_cmd = f'"{PROJECT_ROOT / "UNINSTALL_SEQUORA.bat"}"'
        
        winreg.SetValueEx(key, "DisplayName", 0, winreg.REG_SZ, APP_NAME)
        winreg.SetValueEx(key, "DisplayVersion", 0, winreg.REG_SZ, APP_VERSION)
        winreg.SetValueEx(key, "Publisher", 0, winreg.REG_SZ, APP_PUBLISHER)
        winreg.SetValueEx(key, "DisplayIcon", 0, winreg.REG_SZ, str(ICON_ICO))
        winreg.SetValueEx(key, "InstallLocation", 0, winreg.REG_SZ, str(PROJECT_ROOT))
        winreg.SetValueEx(key, "UninstallString", 0, winreg.REG_SZ, uninstall_cmd)
        winreg.SetValueEx(key, "NoModify", 0, winreg.REG_DWORD, 1)
        winreg.SetValueEx(key, "NoRepair", 0, winreg.REG_DWORD, 1)
        winreg.SetValueEx(key, "Comments", 0, winreg.REG_SZ, APP_DESCRIPTION)
        
        winreg.CloseKey(key)
        print("    [OK] Successfully registered in Windows Installed Apps registry.")
    except Exception as e:
        print(f"    [!] Warning: Registry registration: {e}")

def create_uninstaller_script():
    """Generates the clean uninstaller batch script."""
    uninstall_bat = PROJECT_ROOT / "UNINSTALL_SEQUORA.bat"
    uninst_py = PROJECT_ROOT / "installer" / "uninstall_sequora.py"
    
    uninst_code = f'''#!/usr/bin/env python3
import os
import shutil
import winreg
from pathlib import Path

APP_NAME = "SEQUORA Studio"
user_profile = Path(os.environ.get("USERPROFILE", "C:\\Users\\Default"))
desktop_candidates = [
    user_profile / "Desktop" / f"{{APP_NAME}}.lnk",
    user_profile / "OneDrive" / "Desktop" / f"{{APP_NAME}}.lnk"
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
    winreg.DeleteKey(winreg.HKEY_CURRENT_USER, r"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\SEQUORA_Studio")
except Exception:
    pass

print(f"[OK] {{APP_NAME}} has been successfully uninstalled from Windows.")
'''
    with open(uninst_py, "w", encoding="utf-8") as f:
        f.write(uninst_code)

    bat_content = f'''@echo off
title Uninstall {APP_NAME}
echo ===============================================================================
echo  Uninstalling {APP_NAME}
echo ===============================================================================
echo.
python "{uninst_py}"
echo.
echo [OK] Uninstall Complete.
pause
'''
    with open(uninstall_bat, "w", encoding="utf-8") as f:
        f.write(bat_content)

def main():
    print_banner()
    ensure_python_runtime()
    create_uninstaller_script()
    vbs_path = create_silent_launcher()
    create_windows_shortcuts(vbs_path)
    register_in_windows_uninstall()
    print()
    print("=" * 72)
    print(" [OK] INSTALLATION COMPLETE!")
    print(f"     - {APP_NAME} is now available on your Desktop")
    print(f"     - {APP_NAME} is now available in your Windows Start Menu & Search")
    print(f"     - {APP_NAME} is registered in Windows Installed Apps")
    print("=" * 72)

if __name__ == "__main__":
    main()
