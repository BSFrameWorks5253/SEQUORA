#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA Studio — Build Engine, Auto-Increment & GitHub Release System
===============================================================================
 Features:
   1. Automatic SemVer incrementing (Patch, Minor, Major) in version.txt
   2. Standalone PyInstaller compilation with all QML plugins & assets
   3. Automated ZIP release packaging & checksum generation
   4. Update manifest generator (version.json for auto-updates)
   5. Git staging, tagging (vX.X.X), and automated GitHub push
===============================================================================
"""

import os
import sys
import shutil
import zipfile
import subprocess
import json
import time
from pathlib import Path

# Paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
STUDIO_DIR = PROJECT_ROOT / "SEQUORA_Studio"
ASSETS_DIR = PROJECT_ROOT / "assets"
DIST_DIR = PROJECT_ROOT / "dist"
RELEASES_DIR = DIST_DIR / "releases"
VERSION_FILE = PROJECT_ROOT / "version.txt"
STUDIO_VERSION_FILE = STUDIO_DIR / "version.txt"
ICON_ICO = ASSETS_DIR / "icon.ico"


def get_current_version() -> str:
    """Reads current version from version.txt (defaults to 3.0.0)."""
    if VERSION_FILE.exists():
        try:
            with open(VERSION_FILE, "r", encoding="utf-8") as f:
                v = f.read().strip()
                if v:
                    return v
        except Exception:
            pass
    return "3.0.0"


def increment_version(bump_type="patch", custom_version=None) -> str:
    """
    Increments semver version:
      - 'patch': 3.0.0 -> 3.0.1
      - 'minor': 3.0.0 -> 3.1.0
      - 'major': 3.0.0 -> 4.0.0
      - custom: explicit version string
    """
    if custom_version and custom_version.strip():
        new_v = custom_version.strip().lstrip("v")
    else:
        current = get_current_version().lstrip("v")
        parts = current.split(".")
        while len(parts) < 3:
            parts.append("0")
        
        try:
            major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])
        except ValueError:
            major, minor, patch = 3, 0, 0

        if bump_type == "major":
            major += 1
            minor = 0
            patch = 0
        elif bump_type == "minor":
            minor += 1
            patch = 0
        else:  # patch
            patch += 1

        new_v = f"{major}.{minor}.{patch}"

    # Write to both version files
    for vf in [VERSION_FILE, STUDIO_VERSION_FILE]:
        try:
            vf.parent.mkdir(parents=True, exist_ok=True)
            with open(vf, "w", encoding="utf-8") as f:
                f.write(new_v + "\n")
        except Exception as e:
            print(f"[!] Warning: Writing version to {vf}: {e}")

    return new_v


def ensure_pyinstaller():
    """Ensure PyInstaller is installed."""
    try:
        import PyInstaller
        return True
    except ImportError:
        print("[*] Installing PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
        return True


def build_pyinstaller_exe(version: str, log_callback=None) -> bool:
    """Compiles SEQUORA Studio into standalone Windows Executable using PyInstaller."""
    def log(msg):
        if log_callback:
            log_callback(msg)
        else:
            print(msg)

    log(f"[*] Starting PyInstaller build for SEQUORA Studio v{version}...")
    ensure_pyinstaller()

    main_script = STUDIO_DIR / "main.py"
    if not main_script.exists():
        log(f"[ERROR] Main script not found at: {main_script}")
        return False

    DIST_DIR.mkdir(parents=True, exist_ok=True)
    build_work_dir = DIST_DIR / "build_temp"

    # Assemble PyInstaller command
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--noconfirm",
        "--clean",
        "--windowed",
        "--name", "SEQUORA Studio",
        f"--icon={str(ICON_ICO)}",
        f"--distpath={str(DIST_DIR)}",
        f"--workpath={str(build_work_dir)}",
        f"--specpath={str(DIST_DIR)}",
        # Embed QML and Assets
        f"--add-data={str(STUDIO_DIR / 'qml')}{os.pathsep}qml",
        f"--add-data={str(STUDIO_DIR / 'assets')}{os.pathsep}assets",
        f"--add-data={str(ASSETS_DIR)}{os.pathsep}assets",
        f"--add-data={str(VERSION_FILE)}{os.pathsep}.",
        # Hidden Imports
        "--hidden-import=PySide6.QtQuick",
        "--hidden-import=PySide6.QtQml",
        "--hidden-import=PySide6.QtCore",
        "--hidden-import=PySide6.QtGui",
        "--hidden-import=PySide6.QtWidgets",
        "--hidden-import=openpyxl",
        "--hidden-import=PIL",
        "--hidden-import=csv",
        "--hidden-import=json",
        str(main_script)
    ]

    log(f"[*] Executing PyInstaller compiler...")
    process = subprocess.Popen(
        cmd,
        cwd=str(PROJECT_ROOT),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace"
    )

    for line in process.stdout:
        log(line.rstrip())

    process.wait()

    if process.returncode != 0:
        log(f"[ERROR] PyInstaller compilation failed with code {process.returncode}")
        return False

    log("[OK] PyInstaller compilation finished successfully.")
    
    # Copy assets & launcher to output folder
    out_dir = DIST_DIR / "SEQUORA Studio"
    if out_dir.exists():
        # Copy version.txt into dist folder
        shutil.copy(str(VERSION_FILE), str(out_dir / "version.txt"))
        log(f"[OK] Standalone distribution ready at: {out_dir}")
        return True
    return False


def package_zip_release(version: str, log_callback=None) -> Path:
    """Packages the compiled dist/SEQUORA Studio into a standalone ZIP release archive."""
    def log(msg):
        if log_callback:
            log_callback(msg)
        else:
            print(msg)

    RELEASES_DIR.mkdir(parents=True, exist_ok=True)
    src_dir = DIST_DIR / "SEQUORA Studio"
    zip_path = RELEASES_DIR / f"SEQUORA_Studio_v{version}_Windows_x64.zip"

    if not src_dir.exists():
        log(f"[!] Source build directory not found: {src_dir}")
        return None

    log(f"[*] Packaging ZIP archive: {zip_path.name}...")
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(src_dir):
            for file in files:
                abs_file = Path(root) / file
                rel_file = abs_file.relative_to(src_dir)
                zipf.write(abs_file, arcname=Path("SEQUORA Studio") / rel_file)

    log(f"[OK] ZIP Release created ({os.path.getsize(zip_path) / (1024*1024):.1f} MB)")

    # Generate version.json / update manifest
    manifest = {
        "appName": "SEQUORA Studio",
        "latestVersion": version,
        "releaseDate": time.strftime("%Y-%m-%d %H:%M:%S"),
        "downloadUrl": f"https://github.com/releases/download/v{version}/{zip_path.name}",
        "zipName": zip_path.name,
        "zipSizeBytes": os.path.getsize(zip_path),
        "notes": f"SEQUORA Studio release v{version} with ultra-fast performance, UI upgrades, and bug fixes."
    }

    manifest_path = RELEASES_DIR / "version.json"
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    log(f"[OK] Update manifest generated at: {manifest_path.name}")
    return zip_path


def build_installer_wizard_exe(version: str, zip_path: Path, log_callback=None) -> Path:
    """Compiles the Setup Wizard into a single standalone Setup.exe containing the entire app."""
    def log(msg):
        if log_callback:
            log_callback(msg)
        else:
            print(msg)

    log(f"[*] Compiling Standalone Setup Wizard for v{version}...")
    setup_script = PROJECT_ROOT / "installer" / "setup_wizard.py"
    if not setup_script.exists():
        log(f"[!] Setup script not found: {setup_script}")
        return None

    installer_output_name = f"SEQUORA_Studio_Setup_v{version}"
    build_work = DIST_DIR / "build_setup_temp"

    # Temporary payload path for embedding
    payload_dest = PROJECT_ROOT / "installer" / "payload.zip"
    if zip_path and zip_path.exists():
        shutil.copy(str(zip_path), str(payload_dest))

    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--noconfirm",
        "--clean",
        "--onefile",
        "--windowed",
        "--name", installer_output_name,
        f"--icon={str(ICON_ICO)}",
        f"--distpath={str(RELEASES_DIR)}",
        f"--workpath={str(build_work)}",
        f"--specpath={str(DIST_DIR)}",
        f"--add-data={str(payload_dest)}{os.pathsep}.",
        f"--add-data={str(ICON_ICO)}{os.pathsep}assets",
        "--hidden-import=PySide6.QtCore",
        "--hidden-import=PySide6.QtGui",
        "--hidden-import=PySide6.QtWidgets",
        str(setup_script)
    ]

    log("[*] Building standalone Setup installer (.exe)...")
    p = subprocess.Popen(
        cmd,
        cwd=str(PROJECT_ROOT),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace"
    )
    for line in p.stdout:
        log(line.rstrip())
    p.wait()

    # Clean temporary payload file
    if payload_dest.exists():
        try:
            payload_dest.unlink()
        except Exception:
            pass

    out_installer = RELEASES_DIR / f"{installer_output_name}.exe"
    if out_installer.exists():
        log(f"[OK] Standalone Setup Installer compiled: {out_installer.name} ({out_installer.stat().st_size / (1024*1024):.1f} MB)")
        return out_installer
    else:
        log("[!] Failed to generate installer exe.")
        return None


def publish_github_release(version: str, zip_path: Path = None, installer_exe: Path = None, notes: str = "", token: str = "", repo_slug: str = "BSFrameWorks5253/SEQUORA", branch: str = "main", log_callback=None) -> bool:
    """
    Pushes git commits/tags to GitHub and uploads release asset ZIP and Setup.exe via GitHub REST API.
    """
    import urllib.request
    import urllib.error

    def log(msg):
        if log_callback:
            log_callback(msg)
        else:
            print(msg)

    tag_name = f"v{version}"
    repo_slug = repo_slug.strip().replace("https://github.com/", "").replace(".git", "").strip("/")
    if not repo_slug:
        repo_slug = "BSFrameWorks5253/SEQUORA"

    log(f"[*] Publishing GitHub Release {tag_name} to {repo_slug}...")

    # 1. Git Init / Remote & Push
    try:
        git_dir = PROJECT_ROOT / ".git"
        if not git_dir.exists():
            log("[*] Initializing local git repository...")
            subprocess.run(["git", "init"], cwd=str(PROJECT_ROOT), check=True)
            subprocess.run(["git", "branch", "-M", branch], cwd=str(PROJECT_ROOT), check=True)

        subprocess.run(["git", "config", "user.name", "BSFrameWorks5253"], cwd=str(PROJECT_ROOT), capture_output=True)
        subprocess.run(["git", "config", "user.email", "bsframeworks5253@gmail.com"], cwd=str(PROJECT_ROOT), capture_output=True)

        log("[*] Staging files (git add .)...")
        subprocess.run(["git", "add", "."], cwd=str(PROJECT_ROOT), check=True)

        commit_msg = f"Release {tag_name} — SEQUORA Studio Production Build"
        subprocess.run(["git", "commit", "-m", commit_msg], cwd=str(PROJECT_ROOT), capture_output=True)

        subprocess.run(["git", "tag", "-a", tag_name, "-m", f"SEQUORA Studio {tag_name}", "-f"], cwd=str(PROJECT_ROOT), capture_output=True)

        if token:
            authenticated_url = f"https://{token}@github.com/{repo_slug}.git"
            log(f"[*] Setting authenticated remote for {repo_slug}...")
            remotes = subprocess.run(["git", "remote"], cwd=str(PROJECT_ROOT), capture_output=True, text=True).stdout
            if "origin" in remotes:
                subprocess.run(["git", "remote", "set-url", "origin", authenticated_url], cwd=str(PROJECT_ROOT), capture_output=True)
            else:
                subprocess.run(["git", "remote", "add", "origin", authenticated_url], cwd=str(PROJECT_ROOT), capture_output=True)

            log(f"[*] Pushing commits and tags to GitHub ({branch})...")
            push_res = subprocess.run(["git", "push", "-u", "origin", branch, "--tags", "--force"], cwd=str(PROJECT_ROOT), capture_output=True, text=True)
            if push_res.returncode == 0:
                log("[OK] Git branch and release tags pushed successfully!")
            else:
                log(f"[!] Git push: {push_res.stderr.strip() or push_res.stdout.strip()}")
    except Exception as ge:
        log(f"[!] Git setup warning: {ge}")

    if not token:
        log("[NOTICE] No GitHub Token provided. Skipping GitHub API Release binary upload.")
        return True

    # 2. Create GitHub Release via REST API
    release_data = {
        "tag_name": tag_name,
        "target_commitish": branch,
        "name": f"SEQUORA Studio {tag_name}",
        "body": notes or f"SEQUORA Studio official release {tag_name} for Windows x64.",
        "draft": False,
        "prerelease": False
    }

    create_url = f"https://api.github.com/repos/{repo_slug}/releases"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "SEQUORA-Studio-Publisher/3.0"
    }

    try:
        req = urllib.request.Request(
            create_url,
            data=json.dumps(release_data).encode("utf-8"),
            headers=headers,
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            res_json = json.loads(resp.read().decode("utf-8"))

        release_id = res_json.get("id")
        upload_url_tpl = res_json.get("upload_url", "")
        html_url = res_json.get("html_url", "")
        log(f"[OK] GitHub Release created: {html_url}")

        # 3. Upload Binary Assets (Setup.exe & ZIP archive)
        assets_to_upload = []
        if installer_exe and installer_exe.exists():
            assets_to_upload.append(installer_exe)
        if zip_path and zip_path.exists():
            assets_to_upload.append(zip_path)

        for asset in assets_to_upload:
            clean_upload_url = upload_url_tpl.split("{")[0] + f"?name={asset.name}"
            log(f"[*] Uploading release asset: {asset.name} ({os.path.getsize(asset)/(1024*1024):.1f} MB)...")
            
            with open(asset, "rb") as af:
                asset_bytes = af.read()

            content_type = "application/x-msdownload" if asset.name.endswith(".exe") else "application/zip"
            upload_headers = {
                "Authorization": f"token {token}",
                "Content-Type": content_type,
                "Content-Length": str(len(asset_bytes)),
                "User-Agent": "SEQUORA-Studio-Publisher/3.0"
            }
            up_req = urllib.request.Request(clean_upload_url, data=asset_bytes, headers=upload_headers, method="POST")
            with urllib.request.urlopen(up_req, timeout=600) as up_resp:
                up_json = json.loads(up_resp.read().decode("utf-8"))
                download_url = up_json.get("browser_download_url", "")
                log(f"[OK] {asset.name} uploaded successfully!")
                log(f"[OK] Download URL: {download_url}")

        return True

    except urllib.error.HTTPError as he:
        err_msg = he.read().decode("utf-8", errors="replace")
        log(f"[!] GitHub API HTTP Error {he.code}: {err_msg}")
        return False
    except Exception as e:
        log(f"[ERROR] GitHub release upload error: {e}")
        return False


def git_push_release(version: str, commit_msg=None, remote="origin", branch="main", log_callback=None) -> bool:
    """Stages changes, commits with release tag, and pushes to remote GitHub repository."""
    def log(msg):
        if log_callback:
            log_callback(msg)
        else:
            print(msg)

    log(f"[*] Git Push Release v{version} initiated...")

    # Check git repo
    git_dir = PROJECT_ROOT / ".git"
    if not git_dir.exists():
        log("[*] Initializing local git repository...")
        subprocess.run(["git", "init"], cwd=str(PROJECT_ROOT), check=True)

    if not commit_msg or not commit_msg.strip():
        commit_msg = f"Release v{version} — SEQUORA Studio Production Build"

    try:
        log("[*] Staging files (git add .)...")
        subprocess.run(["git", "add", "."], cwd=str(PROJECT_ROOT), check=True)

        log(f"[*] Committing changes: '{commit_msg}'...")
        subprocess.run(["git", "commit", "-m", commit_msg], cwd=str(PROJECT_ROOT), capture_output=True)

        tag_name = f"v{version}"
        log(f"[*] Creating git release tag: {tag_name}...")
        subprocess.run(["git", "tag", "-a", tag_name, "-m", f"SEQUORA Studio {tag_name}"], cwd=str(PROJECT_ROOT), capture_output=True)

        # Check if remote exists
        check_remote = subprocess.run(["git", "remote"], cwd=str(PROJECT_ROOT), capture_output=True, text=True)
        if remote in check_remote.stdout:
            log(f"[*] Pushing commits and tags to remote '{remote}' ({branch})...")
            p = subprocess.run(["git", "push", remote, branch, "--tags"], cwd=str(PROJECT_ROOT), capture_output=True, text=True)
            if p.returncode == 0:
                log("[OK] Successfully pushed release and tags to GitHub!")
                return True
            else:
                log(f"[!] Git push warning: {p.stderr.strip() or p.stdout.strip()}")
        else:
            log(f"[NOTICE] Git remote '{remote}' is not configured yet.")
            log(f"[OK] Local commit and tag '{tag_name}' created successfully.")
            return True

    except Exception as e:
        log(f"[ERROR] Git operation error: {e}")
        return False

    return True
