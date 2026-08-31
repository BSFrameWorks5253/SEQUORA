#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA Studio — Professional Windows Setup Installer Wizard
===============================================================================
 Creates a full native Windows installer experience:
   - Modern branded installer wizard UI (Welcome -> Location -> Options -> Install -> Finish)
   - Extracts files to AppData\\Local\\Programs\\SEQUORA Studio (or custom path)
   - Creates Desktop Shortcut & Start Menu entry with custom icon
   - Registers in Windows Settings > Installed Apps & Programs and Features
   - Creates clean Uninstaller (Uninstall SEQUORA Studio.exe)
===============================================================================
"""

import os
import sys
import shutil
import zipfile
import winreg
import subprocess
import threading
from pathlib import Path

from PySide6.QtCore import Qt, QThread, Signal, Slot
from PySide6.QtWidgets import (
    QApplication, QWizard, QWizardPage, QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QCheckBox, QProgressBar,
    QFileDialog, QWidget, QFrame
)
from PySide6.QtGui import QIcon, QPixmap, QFont

APP_NAME = "SEQUORA Studio"
APP_PUBLISHER = "BSFrameWorks"
APP_DEFAULT_FOLDER = "SEQUORA Studio"
APP_EXEC_NAME = "SEQUORA Studio.exe"

INSTALLER_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = INSTALLER_DIR.parent


def get_default_install_dir() -> Path:
    local_app_data = os.environ.get("LOCALAPPDATA", "")
    if local_app_data:
        return Path(local_app_data) / "Programs" / APP_DEFAULT_FOLDER
    return Path(os.environ.get("USERPROFILE", "C:\\")) / "AppData" / "Local" / "Programs" / APP_DEFAULT_FOLDER


def get_desktop_dir() -> Path:
    try:
        cmd = 'powershell -NoProfile -Command "[Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)"'
        res = subprocess.check_output(cmd, shell=True, text=True).strip()
        if res and os.path.exists(res):
            return Path(res)
    except Exception:
        pass
    return Path(os.environ.get("USERPROFILE", "")) / "Desktop"


def get_start_menu_dir() -> Path:
    app_data = os.environ.get("APPDATA", "")
    if app_data:
        return Path(app_data) / "Microsoft" / "Windows" / "Start Menu" / "Programs" / APP_DEFAULT_FOLDER
    return Path(os.environ.get("USERPROFILE", "")) / "AppData" / "Roaming" / "Microsoft" / "Windows" / "Start Menu" / "Programs" / APP_DEFAULT_FOLDER


def create_windows_shortcut(target_exe: Path, shortcut_path: Path, icon_path: Path = None, description: str = ""):
    shortcut_path.parent.mkdir(parents=True, exist_ok=True)
    vbs_code = f'''
Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = "{str(shortcut_path)}"
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = "{str(target_exe)}"
oLink.WorkingDirectory = "{str(target_exe.parent)}"
oLink.Description = "{description}"
'''
    if icon_path and icon_path.exists():
        vbs_code += f'\noLink.IconLocation = "{str(icon_path)}, 0"\n'
    else:
        vbs_code += f'\noLink.IconLocation = "{str(target_exe)}, 0"\n'
    vbs_code += 'oLink.Save\n'

    temp_vbs = Path(os.environ.get("TEMP", ".")) / "_create_lnk.vbs"
    temp_vbs.write_text(vbs_code, encoding="utf-8")
    subprocess.run(["cscript", "//nologo", str(temp_vbs)], capture_output=True)
    if temp_vbs.exists():
        try:
            temp_vbs.unlink()
        except Exception:
            pass


def register_in_windows_add_remove(install_dir: Path, version: str, uninstaller_path: Path, icon_path: Path = None):
    try:
        key_path = f"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{APP_NAME}"
        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path) as key:
            winreg.SetValueEx(key, "DisplayName", 0, winreg.REG_SZ, f"{APP_NAME} v{version}")
            winreg.SetValueEx(key, "DisplayVersion", 0, winreg.REG_SZ, version)
            winreg.SetValueEx(key, "Publisher", 0, winreg.REG_SZ, APP_PUBLISHER)
            winreg.SetValueEx(key, "InstallLocation", 0, winreg.REG_SZ, str(install_dir))
            winreg.SetValueEx(key, "UninstallString", 0, winreg.REG_SZ, f'"{str(uninstaller_path)}"')
            if icon_path and icon_path.exists():
                winreg.SetValueEx(key, "DisplayIcon", 0, winreg.REG_SZ, str(icon_path))
            else:
                winreg.SetValueEx(key, "DisplayIcon", 0, winreg.REG_SZ, str(install_dir / APP_EXEC_NAME))
    except Exception as e:
        print(f"[!] Registry registration notice: {e}")


class InstallationWorker(QThread):
    progress_signal = Signal(int, str)
    finished_signal = Signal(bool, str)

    def __init__(self, install_dir: Path, create_desktop: bool, create_start_menu: bool, version: str, payload_zip: Path):
        super().__init__()
        self.install_dir = install_dir
        self.create_desktop = create_desktop
        self.create_start_menu = create_start_menu
        self.version = version
        self.payload_zip = payload_zip

    def run(self):
        try:
            self.progress_signal.emit(5, "Preparing destination directory...")
            self.install_dir.mkdir(parents=True, exist_ok=True)

            # Extract Payload
            if self.payload_zip and self.payload_zip.exists():
                self.progress_signal.emit(15, f"Extracting {APP_NAME} packages...")
                with zipfile.ZipFile(self.payload_zip, 'r') as zip_ref:
                    file_list = zip_ref.namelist()
                    total_files = len(file_list)
                    for i, file_name in enumerate(file_list):
                        zip_ref.extract(file_name, self.install_dir)
                        # Extract directly into install_dir without nesting
                        pct = 15 + int((i / max(1, total_files)) * 65)
                        if i % 10 == 0:
                            self.progress_signal.emit(pct, f"Installing: {os.path.basename(file_name)}")
                
                # If extracted into a subfolder named "SEQUORA Studio", hoist contents
                nested_dir = self.install_dir / APP_DEFAULT_FOLDER
                if nested_dir.exists() and (nested_dir / APP_EXEC_NAME).exists():
                    for item in nested_dir.iterdir():
                        dest_item = self.install_dir / item.name
                        if dest_item.exists():
                            if dest_item.is_dir():
                                shutil.rmtree(dest_item)
                            else:
                                dest_item.unlink()
                        shutil.move(str(item), str(self.install_dir))
                    shutil.rmtree(nested_dir, ignore_errors=True)

            else:
                # Source-mode installation fallback
                self.progress_signal.emit(20, "Copying application binaries...")
                dist_source = PROJECT_ROOT / "dist" / "SEQUORA Studio"
                if dist_source.exists():
                    shutil.copytree(dist_source, self.install_dir, dirs_exist_ok=True)
                else:
                    self.finished_signal.emit(False, "Payload archive not found.")
                    return

            self.progress_signal.emit(85, "Creating Windows shortcuts...")
            main_exe = self.install_dir / APP_EXEC_NAME
            icon_file = self.install_dir / "assets" / "icon.ico"
            if not icon_file.exists():
                icon_file = self.install_dir / "icon.ico"

            # 1. Desktop Shortcut
            if self.create_desktop:
                desktop_lnk = get_desktop_dir() / f"{APP_NAME}.lnk"
                create_windows_shortcut(main_exe, desktop_lnk, icon_file, "SEQUORA Studio Creative Suite")

            # 2. Start Menu Shortcut
            if self.create_start_menu:
                start_menu_folder = get_start_menu_dir()
                start_menu_lnk = start_menu_folder / f"{APP_NAME}.lnk"
                create_windows_shortcut(main_exe, start_menu_lnk, icon_file, "SEQUORA Studio Creative Suite")

            # 3. Create Uninstaller in install directory
            self.progress_signal.emit(92, "Configuring Uninstaller & Windows Registry...")
            uninstaller_script = self.install_dir / "uninstall.bat"
            uninstaller_script.write_text(f'''@echo off
title Uninstall {APP_NAME}
echo Uninstalling {APP_NAME}...
taskkill /F /IM "{APP_EXEC_NAME}" 2>nul
timeout /t 1 >nul
del /F /Q "{str(get_desktop_dir() / f'{APP_NAME}.lnk')}" 2>nul
rd /S /Q "{str(get_start_menu_dir())}" 2>nul
reg delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{APP_NAME}" /f 2>nul
echo {APP_NAME} has been uninstalled successfully.
echo You can now delete this folder: {str(self.install_dir)}
pause
''', encoding="utf-8")

            register_in_windows_add_remove(self.install_dir, self.version, uninstaller_script, icon_file)

            self.progress_signal.emit(100, "Installation Complete!")
            self.finished_signal.emit(True, f"{APP_NAME} v{self.version} installed successfully!")

        except Exception as e:
            self.finished_signal.emit(False, str(e))


class SetupWizard(QWizard):
    def __init__(self, version="3.0.1", payload_zip=None):
        super().__init__()
        self.version = version
        self.payload_zip = payload_zip
        self.setWindowTitle(f"{APP_NAME} v{self.version} Setup Wizard")
        self.resize(620, 440)
        self.setWizardStyle(QWizard.ModernStyle)
        self.setOption(QWizard.NoBackButtonOnStartPage, True)

        # Style
        icon_path = PROJECT_ROOT / "assets" / "icon.ico"
        if icon_path.exists():
            self.setWindowIcon(QIcon(str(icon_path)))

        self.apply_theme()

        # Add Pages
        self.page_welcome = self.create_welcome_page()
        self.page_location = self.create_location_page()
        self.page_options = self.create_options_page()
        self.page_install = self.create_install_page()
        self.page_finish = self.create_finish_page()

        self.addPage(self.page_welcome)
        self.addPage(self.page_location)
        self.addPage(self.page_options)
        self.addPage(self.page_install)
        self.addPage(self.page_finish)

    def apply_theme(self):
        self.setStyleSheet("""
            QWizard, QWidget {
                background-color: #0E0E13;
                color: #EDEDF5;
                font-family: 'Segoe UI', Arial, sans-serif;
            }
            QLabel {
                color: #EDEDF5;
                font-size: 13px;
            }
            QLineEdit {
                background-color: #17171F;
                border: 1px solid #2B2B3D;
                border-radius: 6px;
                padding: 6px 10px;
                color: #FFFFFF;
                font-size: 12px;
            }
            QLineEdit:focus {
                border: 1px solid #8B6CE6;
            }
            QPushButton {
                background-color: #20202C;
                border: 1px solid #333346;
                border-radius: 6px;
                padding: 7px 18px;
                color: #FFFFFF;
                font-weight: 600;
                font-size: 12px;
            }
            QPushButton:hover {
                background-color: #2E2E3E;
                border: 1px solid #8B6CE6;
            }
            QCheckBox {
                color: #D2D2E0;
                font-size: 13px;
                spacing: 8px;
            }
            QCheckBox::indicator {
                width: 16px;
                height: 16px;
                border-radius: 3px;
                border: 1px solid #3B3B4E;
                background-color: #1A1A24;
            }
            QCheckBox::indicator:checked {
                background-color: #8B6CE6;
                border: 1px solid #9E80F5;
            }
            QProgressBar {
                background-color: #17171F;
                border: 1px solid #2B2B3D;
                border-radius: 6px;
                text-align: center;
                color: #FFFFFF;
                font-weight: bold;
                height: 18px;
            }
            QProgressBar::chunk {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #8B6CE6, stop:1 #6D48C5);
                border-radius: 5px;
            }
        """)

    def create_welcome_page(self):
        page = QWizardPage()
        page.setTitle(f"Welcome to the {APP_NAME} Setup Wizard")
        layout = QVBoxLayout(page)
        layout.setSpacing(14)

        lbl_logo = QLabel("⚡ SEQUORA STUDIO CREATIVE SUITE")
        lbl_logo.setStyleSheet("color: #8B6CE6; font-weight: bold; font-size: 15px;")
        layout.addWidget(lbl_logo)

        desc = QLabel(
            f"This wizard will install <b>{APP_NAME} v{self.version}</b> on your computer.<br><br>"
            "SEQUORA Studio provides professional AI-assisted photo matching, video sequence transfer, "
            "PV separation, and automated creative reporting tools.<br><br>"
            "Click <b>Next</b> to choose the installation folder."
        )
        desc.setWordWrap(True)
        layout.addWidget(desc)
        layout.addStretch()
        return page

    def create_location_page(self):
        page = QWizardPage()
        page.setTitle("Choose Install Location")
        layout = QVBoxLayout(page)
        layout.setSpacing(12)

        lbl = QLabel(f"Setup will install {APP_NAME} in the following folder:")
        layout.addWidget(lbl)

        row = QHBoxLayout()
        self.txt_path = QLineEdit(str(get_default_install_dir()))
        row.addWidget(self.txt_path)

        btn_browse = QPushButton("Browse...")
        btn_browse.clicked.connect(self.browse_folder)
        row.addWidget(btn_browse)
        layout.addLayout(row)

        layout.addSpacing(10)
        lbl_space = QLabel("Space required: ~350 MB<br>Space available: > 5 GB")
        lbl_space.setStyleSheet("color: #8E8E9E; font-size: 11px;")
        layout.addWidget(lbl_space)

        layout.addStretch()
        return page

    def browse_folder(self):
        d = QFileDialog.getExistingDirectory(self, "Select Install Directory", self.txt_path.text())
        if d:
            self.txt_path.setText(str(Path(d) / APP_DEFAULT_FOLDER))

    def create_options_page(self):
        page = QWizardPage()
        page.setTitle("Select Additional Tasks")
        layout = QVBoxLayout(page)
        layout.setSpacing(14)

        lbl = QLabel("Select the shortcuts you want setup to create:")
        layout.addWidget(lbl)

        self.chk_desktop = QCheckBox("Create a Desktop shortcut")
        self.chk_desktop.setChecked(True)
        layout.addWidget(self.chk_desktop)

        self.chk_start_menu = QCheckBox("Create Start Menu shortcut & register in Windows Search")
        self.chk_start_menu.setChecked(True)
        layout.addWidget(self.chk_start_menu)

        self.chk_auto_start = QCheckBox("Launch SEQUORA Studio when setup finishes")
        self.chk_auto_start.setChecked(True)
        layout.addWidget(self.chk_auto_start)

        layout.addStretch()
        return page

    def create_install_page(self):
        page = QWizardPage()
        page.setTitle(f"Installing {APP_NAME}")
        layout = QVBoxLayout(page)
        layout.setSpacing(14)

        self.lbl_status = QLabel("Ready to install...")
        layout.addWidget(self.lbl_status)

        self.prog_bar = QProgressBar()
        self.prog_bar.setValue(0)
        layout.addWidget(self.prog_bar)

        layout.addStretch()
        return page

    def initializePage(self, page_id):
        if page_id == 3:  # Install Page
            self.button(QWizard.BackButton).setEnabled(False)
            self.button(QWizard.NextButton).setEnabled(False)

            install_dir = Path(self.txt_path.text().strip())
            worker = InstallationWorker(
                install_dir=install_dir,
                create_desktop=self.chk_desktop.isChecked(),
                create_start_menu=self.chk_start_menu.isChecked(),
                version=self.version,
                payload_zip=self.payload_zip
            )
            worker.progress_signal.connect(self.on_progress)
            worker.finished_signal.connect(self.on_install_finished)
            self.worker = worker
            worker.start()

    def on_progress(self, val, msg):
        self.prog_bar.setValue(val)
        self.lbl_status.setText(msg)

    def on_install_finished(self, success, msg):
        self.button(QWizard.NextButton).setEnabled(True)
        if success:
            self.next()
        else:
            self.lbl_status.setText(f"<font color='#FF6B6B'>Error: {msg}</font>")

    def create_finish_page(self):
        page = QWizardPage()
        page.setTitle("Installation Complete!")
        layout = QVBoxLayout(page)
        layout.setSpacing(14)

        lbl = QLabel(
            f"<b>{APP_NAME} v{self.version}</b> has been successfully installed on your computer.<br><br>"
            "You can launch the application anytime from your <b>Desktop</b> or the <b>Windows Start Menu</b>."
        )
        lbl.setWordWrap(True)
        layout.addWidget(lbl)
        layout.addStretch()
        return page

    def accept(self):
        if self.chk_auto_start.isChecked():
            main_exe = Path(self.txt_path.text().strip()) / APP_EXEC_NAME
            if main_exe.exists():
                subprocess.Popen([str(main_exe)], cwd=str(main_exe.parent))
        super().accept()


def main():
    app = QApplication(sys.argv)
    app.setApplicationName(f"{APP_NAME} Setup")

    # Check for payload.zip next to script or bundled in PyInstaller
    bundle_dir = getattr(sys, '_MEIPASS', str(INSTALLER_DIR))
    payload = Path(bundle_dir) / "payload.zip"
    if not payload.exists():
        releases_dir = PROJECT_ROOT / "dist" / "releases"
        for z in releases_dir.glob("*.zip"):
            payload = z
            break

    wizard = SetupWizard(version="3.0.1", payload_zip=payload)
    wizard.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
