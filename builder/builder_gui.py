#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA Studio — Standalone EXE Builder & GitHub Publisher GUI
===============================================================================
 Modern PySide6 Desktop GUI for building, versioning, and releasing SEQUORA Studio.
===============================================================================
"""

import os
import sys
import threading
import subprocess
from pathlib import Path

# Paths
BUILDER_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = BUILDER_DIR.parent
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(BUILDER_DIR))

from PySide6.QtCore import Qt, QThread, Signal, Slot, QTimer
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QLineEdit, QTextEdit, QProgressBar,
    QCheckBox, QRadioButton, QButtonGroup, QGroupBox, QFrame,
    QFileDialog, QMessageBox
)
from PySide6.QtGui import QIcon, QFont, QColor, QTextCursor

import builder_engine

class BuildWorkerThread(QThread):
    log_signal = Signal(str)
    progress_signal = Signal(int)
    finished_signal = Signal(bool, str)

    def __init__(self, build_exe, make_zip, build_installer, do_git, bump_mode, custom_ver, commit_msg, remote, branch, repo_slug, token):
        super().__init__()
        self.build_exe = build_exe
        self.make_zip = make_zip
        self.build_installer = build_installer
        self.do_git = do_git
        self.bump_mode = bump_mode
        self.custom_ver = custom_ver
        self.commit_msg = commit_msg
        self.remote = remote
        self.branch = branch
        self.repo_slug = repo_slug
        self.token = token

    def run(self):
        try:
            self.progress_signal.emit(10)
            # 1. Version Increment
            if self.bump_mode:
                new_version = builder_engine.increment_version(self.bump_mode, self.custom_ver)
                self.log_signal.emit(f"[OK] Incremented version to v{new_version}")
            else:
                new_version = builder_engine.get_current_version()
                self.log_signal.emit(f"[*] Building existing version v{new_version}")

            self.progress_signal.emit(25)

            # 2. Build Standalone App Folder EXE
            if self.build_exe:
                self.log_signal.emit("[*] Compiling Standalone Windows Executable...")
                ok = builder_engine.build_pyinstaller_exe(new_version, log_callback=self.log_signal.emit)
                if not ok:
                    self.finished_signal.emit(False, "PyInstaller compilation failed.")
                    return

            self.progress_signal.emit(55)

            # 3. Package ZIP
            zip_path = None
            if self.make_zip or self.build_installer:
                self.log_signal.emit("[*] Packaging ZIP distribution & manifest...")
                zip_path = builder_engine.package_zip_release(new_version, log_callback=self.log_signal.emit)
                if not zip_path:
                    self.log_signal.emit("[!] Warning: ZIP packaging skipped (dist folder missing).")

            self.progress_signal.emit(75)

            # 4. Build Standalone Setup.exe Installer
            installer_exe = None
            if self.build_installer and zip_path:
                self.log_signal.emit("[*] Compiling Single-File Setup Wizard Installer (Setup.exe)...")
                installer_exe = builder_engine.build_installer_wizard_exe(new_version, zip_path, log_callback=self.log_signal.emit)

            self.progress_signal.emit(88)

            # 5. Git Push & GitHub Release Publishing
            if self.do_git:
                self.log_signal.emit(f"[*] Publishing release v{new_version} to GitHub ({self.repo_slug})...")
                builder_engine.publish_github_release(
                    version=new_version,
                    zip_path=zip_path,
                    installer_exe=installer_exe,
                    notes=self.commit_msg,
                    token=self.token,
                    repo_slug=self.repo_slug,
                    branch=self.branch,
                    log_callback=self.log_signal.emit
                )

            self.progress_signal.emit(100)
            self.finished_signal.emit(True, f"SEQUORA Studio v{new_version} build successfully completed!")

        except Exception as e:
            self.log_signal.emit(f"[ERROR] Build process error: {e}")
            self.finished_signal.emit(False, str(e))


class BuilderMainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("SEQUORA Studio — EXE Builder & GitHub Release Engine")
        self.resize(920, 720)
        self.setMinimumSize(800, 600)

        # Set Icon
        icon_path = PROJECT_ROOT / "assets" / "icon.ico"
        if icon_path.exists():
            self.setWindowIcon(QIcon(str(icon_path)))

        self.apply_dark_theme()
        self.init_ui()
        self.refresh_version_display()

    def apply_dark_theme(self):
        self.setStyleSheet("""
            QMainWindow, QWidget {
                background-color: #0D0D11;
                color: #F8F8FC;
                font-family: 'Segoe UI', Arial, sans-serif;
            }
            QGroupBox {
                background-color: #17171E;
                border: 1px solid #262633;
                border-radius: 8px;
                margin-top: 18px;
                padding-top: 14px;
                font-weight: bold;
                font-size: 12px;
                color: #8B6CE6;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 14px;
                padding: 0 6px;
            }
            QLineEdit, QTextEdit {
                background-color: #111116;
                border: 1px solid #2A2A38;
                border-radius: 6px;
                padding: 6px 10px;
                color: #F8F8FC;
                font-size: 12px;
            }
            QLineEdit:focus, QTextEdit:focus {
                border: 1px solid #8B6CE6;
            }
            QRadioButton, QCheckBox {
                color: #E2E2EC;
                font-size: 12px;
                spacing: 8px;
            }
            QRadioButton::indicator, QCheckBox::indicator {
                width: 16px;
                height: 16px;
                border-radius: 3px;
                border: 1px solid #3A3A4D;
                background-color: #1A1A24;
            }
            QRadioButton::indicator:checked, QCheckBox::indicator:checked {
                background-color: #8B6CE6;
                border: 1px solid #9E80F5;
            }
            QPushButton {
                background-color: #22222E;
                border: 1px solid #333344;
                border-radius: 6px;
                padding: 8px 16px;
                color: #F8F8FC;
                font-weight: 600;
                font-size: 12px;
            }
            QPushButton:hover {
                background-color: #2C2C3C;
                border: 1px solid #8B6CE6;
            }
            QPushButton:pressed {
                background-color: #1B1B25;
            }
            QProgressBar {
                background-color: #14141A;
                border: 1px solid #262633;
                border-radius: 6px;
                text-align: center;
                color: #FFFFFF;
                font-weight: bold;
                height: 14px;
            }
            QProgressBar::chunk {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #8B6CE6, stop:1 #6D48C5);
                border-radius: 5px;
            }
        """)

    def init_ui(self):
        main_widget = QWidget()
        main_layout = QVBoxLayout(main_widget)
        main_layout.setContentsMargins(20, 16, 20, 16)
        main_layout.setSpacing(14)

        # ── Header ────────────────────────────────────────────────────────────
        hdr_layout = QHBoxLayout()
        hdr_title = QLabel("⚡ SEQUORA Studio — EXE Builder & Release System")
        hdr_title.setFont(QFont("Segoe UI", 14, QFont.Bold))
        hdr_title.setStyleSheet("color: #F8F8FC;")
        hdr_layout.addWidget(hdr_title)
        hdr_layout.addStretch()

        self.ver_badge = QLabel("v3.0.0")
        self.ver_badge.setStyleSheet("""
            background-color: #261E3B;
            color: #9E80F5;
            border: 1px solid #8B6CE6;
            border-radius: 12px;
            padding: 4px 12px;
            font-weight: bold;
            font-size: 11px;
        """)
        hdr_layout.addWidget(self.ver_badge)
        main_layout.addLayout(hdr_layout)

        # ── 1. Version Manager Panel ──────────────────────────────────────────
        ver_group = QGroupBox("1. VERSIONING & BUILD INCREMENT")
        ver_layout = QVBoxLayout(ver_group)
        ver_layout.setSpacing(10)

        r_layout = QHBoxLayout()
        self.chk_autoincrement = QCheckBox("Auto-Increment version on build")
        self.chk_autoincrement.setChecked(True)
        self.chk_autoincrement.toggled.connect(self.update_version_preview)
        r_layout.addWidget(self.chk_autoincrement)
        r_layout.addSpacing(20)

        self.rb_patch = QRadioButton("Patch (+0.0.1)")
        self.rb_patch.setChecked(True)
        self.rb_patch.toggled.connect(self.update_version_preview)
        r_layout.addWidget(self.rb_patch)

        self.rb_minor = QRadioButton("Minor (+0.1.0)")
        self.rb_minor.toggled.connect(self.update_version_preview)
        r_layout.addWidget(self.rb_minor)

        self.rb_major = QRadioButton("Major (+1.0.0)")
        self.rb_major.toggled.connect(self.update_version_preview)
        r_layout.addWidget(self.rb_major)

        self.rb_custom = QRadioButton("Custom:")
        self.rb_custom.toggled.connect(self.update_version_preview)
        r_layout.addWidget(self.rb_custom)

        self.txt_custom_ver = QLineEdit()
        self.txt_custom_ver.setPlaceholderText("e.g. 3.1.0")
        self.txt_custom_ver.setFixedWidth(90)
        self.txt_custom_ver.textChanged.connect(self.update_version_preview)
        r_layout.addWidget(self.txt_custom_ver)

        r_layout.addStretch()

        self.lbl_next_ver = QLabel("Target Build: v3.0.1")
        self.lbl_next_ver.setStyleSheet("color: #34D399; font-weight: bold; font-size: 12px;")
        r_layout.addWidget(self.lbl_next_ver)

        ver_layout.addLayout(r_layout)
        main_layout.addWidget(ver_group)

        # ── 2. Build & Release Options ────────────────────────────────────────
        opt_group = QGroupBox("2. PACKAGING & GITHUB RELEASE OPTIONS")
        opt_layout = QVBoxLayout(opt_group)
        opt_layout.setSpacing(10)

        row1 = QHBoxLayout()
        self.chk_build_exe = QCheckBox("Compile Standalone Windows Executable (.exe)")
        self.chk_build_exe.setChecked(True)
        row1.addWidget(self.chk_build_exe)

        self.chk_build_installer = QCheckBox("Build Single-File Setup Wizard Installer (Setup.exe)")
        self.chk_build_installer.setChecked(True)
        row1.addWidget(self.chk_build_installer)

        self.chk_make_zip = QCheckBox("Package ZIP Release")
        self.chk_make_zip.setChecked(True)
        row1.addWidget(self.chk_make_zip)
        row1.addStretch()
        opt_layout.addLayout(row1)

        row2 = QHBoxLayout()
        self.chk_git_push = QCheckBox("Publish Release & Upload Executable Asset to GitHub")
        self.chk_git_push.setChecked(True)
        row2.addWidget(self.chk_git_push)

        row2.addSpacing(14)
        row2.addWidget(QLabel("Repository:"))
        self.txt_repo = QLineEdit("BSFrameWorks5253/SEQUORA")
        self.txt_repo.setFixedWidth(180)
        row2.addWidget(self.txt_repo)

        row2.addWidget(QLabel("Branch:"))
        self.txt_branch = QLineEdit("main")
        self.txt_branch.setFixedWidth(60)
        row2.addWidget(self.txt_branch)

        row2.addStretch()
        opt_layout.addLayout(row2)

        row3 = QHBoxLayout()
        row3.addWidget(QLabel("GitHub Token:"))
        self.txt_token = QLineEdit()
        self.txt_token.setEchoMode(QLineEdit.Password)
        self.txt_token.setPlaceholderText("ghp_...")
        
        # Load local token if saved
        local_tok_file = BUILDER_DIR / ".github_token"
        if local_tok_file.exists():
            try:
                self.txt_token.setText(local_tok_file.read_text(encoding="utf-8").strip())
            except Exception:
                pass
        row3.addWidget(self.txt_token)

        self.btn_show_token = QPushButton("Show")
        self.btn_show_token.setFixedWidth(55)
        self.btn_show_token.clicked.connect(self.toggle_token_visibility)
        row3.addWidget(self.btn_show_token)

        row3.addSpacing(10)
        row3.addWidget(QLabel("Release Notes:"))
        self.txt_commit_msg = QLineEdit()
        self.txt_commit_msg.setPlaceholderText("Release notes & changelog summary...")
        row3.addWidget(self.txt_commit_msg)

        opt_layout.addLayout(row3)
        main_layout.addWidget(opt_group)

        # ── 3. Terminal Log Output ────────────────────────────────────────────
        term_group = QGroupBox("3. LIVE COMPILATION & RELEASE LOG")
        term_layout = QVBoxLayout(term_group)
        term_layout.setSpacing(8)

        self.txt_logs = QTextEdit()
        self.txt_logs.setReadOnly(True)
        self.txt_logs.setFont(QFont("Consolas", 10))
        self.txt_logs.setStyleSheet("""
            background-color: #0A0A0E;
            color: #A0A0B2;
            border: 1px solid #1E1E28;
            border-radius: 6px;
        """)
        term_layout.addWidget(self.txt_logs)

        self.prog_bar = QProgressBar()
        self.prog_bar.setValue(0)
        term_layout.addWidget(self.prog_bar)

        main_layout.addWidget(term_group)

        # ── 4. Action Buttons Footer ──────────────────────────────────────────
        btn_layout = QHBoxLayout()

        self.btn_build = QPushButton("🚀 BUILD EXE & PACKAGE RELEASE")
        self.btn_build.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #8B6CE6, stop:1 #6D48C5);
                border: 1px solid #9E80F5;
                color: #FFFFFF;
                font-size: 13px;
                padding: 10px 24px;
                font-weight: bold;
                border-radius: 6px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #9E80F5, stop:1 #7D56D8);
            }
            QPushButton:disabled {
                background: #22222E;
                color: #666677;
                border: 1px solid #333344;
            }
        """)
        self.btn_build.clicked.connect(self.start_build)
        btn_layout.addWidget(self.btn_build)

        self.btn_open_dist = QPushButton("📂 Open Output Folder")
        self.btn_open_dist.clicked.connect(self.open_output_dir)
        btn_layout.addWidget(self.btn_open_dist)

        self.btn_clear_logs = QPushButton("Clear Logs")
        self.btn_clear_logs.clicked.connect(self.txt_logs.clear)
        btn_layout.addWidget(self.btn_clear_logs)

        btn_layout.addStretch()

        main_layout.addLayout(btn_layout)
        self.setCentralWidget(main_widget)

    def refresh_version_display(self):
        curr = builder_engine.get_current_version()
        self.ver_badge.setText(f"Current: v{curr}")
        self.update_version_preview()

    def update_version_preview(self):
        curr = builder_engine.get_current_version().lstrip("v")
        if not self.chk_autoincrement.isChecked():
            self.lbl_next_ver.setText(f"Target Build: v{curr} (no bump)")
            return

        if self.rb_custom.isChecked():
            tgt = self.txt_custom_ver.text().strip() or curr
            self.lbl_next_ver.setText(f"Target Build: v{tgt}")
            return

        parts = curr.split(".")
        while len(parts) < 3:
            parts.append("0")
        try:
            major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])
        except ValueError:
            major, minor, patch = 3, 0, 0

        if self.rb_major.isChecked():
            major += 1; minor = 0; patch = 0
        elif self.rb_minor.isChecked():
            minor += 1; patch = 0
        else:
            patch += 1

        self.lbl_next_ver.setText(f"Target Build: v{major}.{minor}.{patch}")

    def append_log(self, text):
        color = "#A0A0B2"
        if "[OK]" in text or "successfully" in text.lower():
            color = "#34D399"
        elif "[ERROR]" in text or "error" in text.lower():
            color = "#F87171"
        elif "[*]" in text:
            color = "#9E80F5"
        elif "[!]" in text or "[NOTICE]" in text:
            color = "#FBBF24"

        self.txt_logs.append(f'<span style="color: {color};">{text}</span>')
        self.txt_logs.moveCursor(QTextCursor.End)

    def toggle_token_visibility(self):
        if self.txt_token.echoMode() == QLineEdit.Password:
            self.txt_token.setEchoMode(QLineEdit.Normal)
            self.btn_show_token.setText("Hide")
        else:
            self.txt_token.setEchoMode(QLineEdit.Password)
            self.btn_show_token.setText("Show")

    def start_build(self):
        self.btn_build.setEnabled(False)
        self.prog_bar.setValue(5)
        self.txt_logs.clear()
        self.append_log("[*] Initializing SEQUORA Studio Build Pipeline...")

        bump_mode = None
        custom_ver = None
        if self.chk_autoincrement.isChecked():
            if self.rb_major.isChecked():
                bump_mode = "major"
            elif self.rb_minor.isChecked():
                bump_mode = "minor"
            elif self.rb_custom.isChecked():
                bump_mode = "custom"
                custom_ver = self.txt_custom_ver.text().strip()
            else:
                bump_mode = "patch"

        self.worker = BuildWorkerThread(
            build_exe=self.chk_build_exe.isChecked(),
            make_zip=self.chk_make_zip.isChecked(),
            build_installer=self.chk_build_installer.isChecked(),
            do_git=self.chk_git_push.isChecked(),
            bump_mode=bump_mode,
            custom_ver=custom_ver,
            commit_msg=self.txt_commit_msg.text().strip(),
            remote="origin",
            branch=self.txt_branch.text().strip() or "main",
            repo_slug=self.txt_repo.text().strip() or "BSFrameWorks5253/SEQUORA",
            token=self.txt_token.text().strip()
        )
        self.worker.log_signal.connect(self.append_log)
        self.worker.progress_signal.connect(self.prog_bar.setValue)
        self.worker.finished_signal.connect(self.on_build_finished)
        self.worker.start()

    def on_build_finished(self, success, message):
        self.btn_build.setEnabled(True)
        self.refresh_version_display()
        if success:
            QMessageBox.information(self, "Build Complete", message)
        else:
            QMessageBox.critical(self, "Build Failed", message)

    def open_output_dir(self):
        dist_dir = PROJECT_ROOT / "dist"
        dist_dir.mkdir(parents=True, exist_ok=True)
        subprocess.run(["explorer", str(dist_dir)])


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("SEQUORA Studio Builder")
    window = BuilderMainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
