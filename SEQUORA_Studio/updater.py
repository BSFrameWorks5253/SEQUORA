#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA Studio — In-App Auto-Updater & GitHub Release Engine
===============================================================================
 Automatically checks GitHub releases and raw version manifests for newer builds,
 displays release notes, downloads update archives with live progress, and
 applies updates seamlessly.
===============================================================================
"""

import os
import sys
import json
import time
import shutil
import zipfile
import tempfile
import urllib.request
import urllib.error
import threading
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property

STUDIO_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = STUDIO_DIR.parent
VERSION_FILE = STUDIO_DIR / "version.txt"

DEFAULT_REPO = "BSFrameWorks5253/SEQUORA"
GITHUB_API_URL = f"https://api.github.com/repos/{DEFAULT_REPO}/releases/latest"
RAW_MANIFEST_URL = f"https://raw.githubusercontent.com/{DEFAULT_REPO}/main/version.json"


def get_local_version() -> str:
    """Reads current installed version from version.txt."""
    if VERSION_FILE.exists():
        try:
            with open(VERSION_FILE, "r", encoding="utf-8") as f:
                v = f.read().strip()
                if v:
                    return v
        except Exception:
            pass
    return "3.0.3"


def parse_semver(v: str):
    v = v.lstrip("v").strip()
    parts = v.split(".")
    while len(parts) < 3:
        parts.append("0")
    try:
        return (int(parts[0]), int(parts[1]), int(parts[2]))
    except ValueError:
        return (0, 0, 0)


class AppUpdaterWrapper(QObject):
    updateCheckingChanged = Signal()
    updateDownloadingChanged = Signal()
    updateAvailable = Signal(str, str, str)  # latest_ver, release_notes, download_url
    noUpdateFound = Signal(str)             # current_version
    checkError = Signal(str)
    downloadProgress = Signal(int, str)     # percent (0-100), statusText
    updateReadyToRestart = Signal(str)     # success_msg
    updateFailed = Signal(str)             # error_msg

    def __init__(self, parent=None):
        super().__init__(parent)
        self._is_checking = False
        self._is_downloading = False
        self._local_version = get_local_version()
        self._latest_version = self._local_version
        self._release_notes = ""
        self._download_url = ""
        self._download_percent = 0

    @Property(str, constant=True)
    def currentVersion(self):
        return self._local_version

    @Property(str, notify=updateCheckingChanged)
    def latestVersion(self):
        return self._latest_version

    @Property(bool, notify=updateCheckingChanged)
    def isChecking(self):
        return self._is_checking

    @Property(bool, notify=updateDownloadingChanged)
    def isDownloading(self):
        return self._is_downloading

    @Property(int, notify=updateDownloadingChanged)
    def downloadPercent(self):
        return self._download_percent

    @Property(str, notify=updateCheckingChanged)
    def releaseNotes(self):
        return self._release_notes

    @Property(str, notify=updateCheckingChanged)
    def downloadUrl(self):
        return self._download_url

    @Slot()
    @Slot(str)
    def checkForUpdates(self, custom_manifest_url=""):
        """Checks GitHub API with automatic fallback to raw version.json manifest."""
        if self._is_checking or self._is_downloading:
            return

        self._is_checking = True
        self.updateCheckingChanged.emit()

        def worker():
            remote_v = ""
            notes = ""
            down_url = ""
            err_msg = ""

            # Attempt 1: GitHub Releases API
            url = custom_manifest_url.strip() if custom_manifest_url.strip() else GITHUB_API_URL
            try:
                req = urllib.request.Request(
                    url,
                    headers={
                        "User-Agent": "SEQUORA-Studio-Desktop/3.0",
                        "Accept": "application/vnd.github.v3+json"
                    }
                )
                with urllib.request.urlopen(req, timeout=7) as response:
                    data = json.loads(response.read().decode("utf-8"))
                    if "tag_name" in data:
                        remote_v = data.get("tag_name", "").lstrip("v").strip()
                        notes = data.get("body", "Latest production release of SEQUORA Studio.")
                        assets = data.get("assets", [])
                        down_url = assets[0].get("browser_download_url", "") if assets else data.get("zipball_url", "")
                        if not down_url:
                            down_url = data.get("html_url", "")
            except Exception as e1:
                err_msg = str(e1)

            # Attempt 2: Raw version.json fallback (bypasses GitHub API rate limits)
            if not remote_v:
                try:
                    raw_req = urllib.request.Request(
                        RAW_MANIFEST_URL,
                        headers={"User-Agent": "SEQUORA-Studio-Desktop/3.0"}
                    )
                    with urllib.request.urlopen(raw_req, timeout=5) as response:
                        data = json.loads(response.read().decode("utf-8"))
                        remote_v = data.get("latestVersion", "").lstrip("v").strip()
                        notes = data.get("notes", "New release update for SEQUORA Studio.")
                        down_url = data.get("downloadUrl", f"https://github.com/{DEFAULT_REPO}/releases/latest")
                except Exception as e2:
                    if not err_msg:
                        err_msg = str(e2)

            self._is_checking = False
            self.updateCheckingChanged.emit()

            if not remote_v:
                self.checkError.emit(f"Unable to connect to update server: {err_msg}")
                return

            self._latest_version = remote_v
            self._release_notes = notes
            self._download_url = down_url

            local_sem = parse_semver(self._local_version)
            remote_sem = parse_semver(remote_v)

            if remote_sem > local_sem:
                self.updateAvailable.emit(remote_v, notes, down_url)
            else:
                self.noUpdateFound.emit(self._local_version)

        threading.Thread(target=worker, daemon=True).start()

    @Slot()
    @Slot(str)
    def downloadAndInstallUpdate(self, custom_url=""):
        """Downloads update zip package in background and applies updates."""
        target_url = custom_url.strip() if custom_url.strip() else self._download_url
        if not target_url or not target_url.startswith("http"):
            target_url = f"https://github.com/{DEFAULT_REPO}/archive/refs/heads/main.zip"

        if self._is_downloading:
            return

        self._is_downloading = True
        self._download_percent = 0
        self.updateDownloadingChanged.emit()

        def worker():
            temp_zip = Path(tempfile.gettempdir()) / "SEQUORA_Update_Package.zip"
            try:
                self.downloadProgress.emit(5, "Connecting to download server...")
                req = urllib.request.Request(
                    target_url,
                    headers={"User-Agent": "SEQUORA-Studio-Desktop/3.0"}
                )

                with urllib.request.urlopen(req, timeout=30) as response:
                    total_size = int(response.headers.get("content-length", 0))
                    downloaded = 0
                    block_size = 65536

                    with open(temp_zip, "wb") as f_out:
                        while True:
                            chunk = response.read(block_size)
                            if not chunk:
                                break
                            f_out.write(chunk)
                            downloaded += len(chunk)
                            if total_size > 0:
                                pct = int((downloaded / total_size) * 85)
                                self._download_percent = min(85, max(5, pct))
                                mb_down = (downloaded / (1024 * 1024)).toFixed(1) if hasattr(downloaded, 'toFixed') else f"{downloaded / (1024*1024):.1f}"
                                mb_tot = f"{total_size / (1024*1024):.1f}"
                                self.downloadProgress.emit(self._download_percent, f"Downloading: {mb_down} MB / {mb_tot} MB")

                self.downloadProgress.emit(90, "Extracting and applying update files...")
                time.sleep(0.5)

                # Extract and apply files
                if zipfile.is_zipfile(temp_zip):
                    extract_dir = Path(tempfile.gettempdir()) / "SEQUORA_Extracted_Update"
                    if extract_dir.exists():
                        shutil.rmtree(extract_dir, ignore_errors=True)
                    extract_dir.mkdir(parents=True, exist_ok=True)

                    with zipfile.ZipFile(temp_zip, "r") as z:
                        z.extractall(extract_dir)

                    # Look for root or subdirectory in extracted content
                    source_dir = extract_dir
                    subdirs = [d for d in extract_dir.iterdir() if d.is_dir()]
                    if len(subdirs) == 1:
                        source_dir = subdirs[0]

                    # Copy SEQUORA_Studio files
                    src_studio = source_dir / "SEQUORA_Studio" if (source_dir / "SEQUORA_Studio").exists() else source_dir
                    if src_studio.exists():
                        for item in src_studio.glob("**/*"):
                            if item.is_file() and not item.name.endswith(".json"):
                                rel = item.relative_to(src_studio)
                                dst = STUDIO_DIR / rel
                                dst.parent.mkdir(parents=True, exist_ok=True)
                                try:
                                    shutil.copy2(item, dst)
                                except Exception:
                                    pass

                self._download_percent = 100
                self.downloadProgress.emit(100, "Update installed successfully!")
                self._is_downloading = False
                self.updateDownloadingChanged.emit()

                # Update version.txt
                try:
                    if self._latest_version:
                        with open(VERSION_FILE, "w", encoding="utf-8") as vf:
                            vf.write(self._latest_version + "\n")
                        with open(PROJECT_ROOT / "version.txt", "w", encoding="utf-8") as vf2:
                            vf2.write(self._latest_version + "\n")
                except Exception:
                    pass

                self.updateReadyToRestart.emit(f"SEQUORA Studio has been updated to v{self._latest_version}! Restart the app to apply.")

            except Exception as e:
                self._is_downloading = False
                self.updateDownloadingChanged.emit()
                self.updateFailed.emit(f"Failed to download/apply update: {str(e)}")
            finally:
                if temp_zip.exists():
                    try:
                        temp_zip.unlink()
                    except Exception:
                        pass

        threading.Thread(target=worker, daemon=True).start()
