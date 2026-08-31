#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA Studio — In-App Auto-Updater & GitHub Release Checker
===============================================================================
 Automatically checks GitHub releases or raw version.json for newer builds,
 displays release notes, and allows one-click update downloading.
===============================================================================
"""

import os
import sys
import json
import urllib.request
import urllib.error
import threading
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property

STUDIO_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = STUDIO_DIR.parent
VERSION_FILE = STUDIO_DIR / "version.txt"

DEFAULT_REPO = "BSFrameWorks5253/SEQUORA"
DEFAULT_UPDATE_URL = f"https://api.github.com/repos/{DEFAULT_REPO}/releases/latest"


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
    return "3.0.0"


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
    updateAvailable = Signal(str, str, str)  # latest_ver, release_notes, download_url
    noUpdateFound = Signal()
    checkError = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._is_checking = False
        self._local_version = get_local_version()
        self._latest_version = self._local_version
        self._release_notes = ""
        self._download_url = ""

    @Property(str, constant=True)
    def currentVersion(self):
        return self._local_version

    @Property(str, notify=updateCheckingChanged)
    def latestVersion(self):
        return self._latest_version

    @Property(bool, notify=updateCheckingChanged)
    def isChecking(self):
        return self._is_checking

    @Property(str, notify=updateCheckingChanged)
    def releaseNotes(self):
        return self._release_notes

    @Slot(str)
    def checkForUpdates(self, custom_manifest_url=""):
        """Checks remote URL or GitHub for update manifest asynchronously."""
        if self._is_checking:
            return

        self._is_checking = True
        self.updateCheckingChanged.emit()

        url = custom_manifest_url.strip() if custom_manifest_url.strip() else DEFAULT_UPDATE_URL

        def worker():
            try:
                req = urllib.request.Request(
                    url,
                    headers={"User-Agent": "SEQUORA-Studio-AutoUpdater/3.0"}
                )
                with urllib.request.urlopen(req, timeout=8) as response:
                    data = json.loads(response.read().decode("utf-8"))

                if "tag_name" in data:
                    remote_v = data.get("tag_name", "").lstrip("v").strip()
                    notes = data.get("body", "New SEQUORA Studio release.")
                    assets = data.get("assets", [])
                    down_url = assets[0].get("browser_download_url", "") if assets else data.get("html_url", "")
                else:
                    remote_v = data.get("latestVersion", "").lstrip("v").strip()
                    notes = data.get("notes", "New SEQUORA Studio release.")
                    down_url = data.get("downloadUrl", "")

                self._latest_version = remote_v
                self._release_notes = notes
                self._download_url = down_url

                local_sem = parse_semver(self._local_version)
                remote_sem = parse_semver(remote_v)

                self._is_checking = False
                self.updateCheckingChanged.emit()

                if remote_sem > local_sem:
                    self.updateAvailable.emit(remote_v, notes, down_url)
                else:
                    self.noUpdateFound.emit()

            except Exception as e:
                self._is_checking = False
                self.updateCheckingChanged.emit()
                self.checkError.emit(str(e))

        t = threading.Thread(target=worker, daemon=True)
        t.start()
