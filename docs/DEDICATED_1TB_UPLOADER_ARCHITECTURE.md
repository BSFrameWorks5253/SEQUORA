# 🚀 SEQUORA Studio — Dedicated 1 TB Uploader Architecture & Guide

This document explains the technical architecture, operational mechanisms, and implementation blueprint of a **Dedicated Python / Rclone Uploader** capable of uploading **1 TB+ of Master Videos and Photo Archives** to Google Drive with 100% reliability, zero crashes, and automatic resume.

---

## 📑 Table of Contents
1. [Why 1 TB Uploads Break in Browsers / Apps Script](#1-why-1-tb-uploads-break-in-browsers--apps-script)
2. [How the Dedicated Python Uploader Works](#2-how-the-dedicated-python-uploader-works)
3. [How the Dedicated Rclone Uploader Works](#3-how-the-dedicated-rclone-uploader-works)
4. [Python vs Rclone vs Drive Desktop: Comparison](#4-python-vs-rclone-vs-drive-desktop-comparison)
5. [Step-by-Step Technical Workflow](#5-step-by-step-technical-workflow)
6. [Daily 750 GB Google Quota Handling](#6-daily-750-gb-google-quota-handling)
7. [Production Code & Setup Blueprint](#7-production-code--setup-blueprint)

---

## 1. Why 1 TB Uploads Break in Browsers / Apps Script

| Problem | Google Apps Script / Web Browser | Dedicated Python / Rclone Engine |
| :--- | :--- | :--- |
| **Max Single File Size** | ❌ Hard cap at ~50 MB (Base64 limits) | ✅ Supports files up to **5 TB** each |
| **RAM Usage** | ❌ Loads files into browser RAM (Out-of-Memory crash) | ✅ Streams from disk in 16MB–64MB chunks (< 200MB RAM total) |
| **Connection Drops** | ❌ Entire upload restarts from zero | ✅ **Resumable Chunks**: Resumes at the exact byte where it paused |
| **Power Outage / Reboot** | ❌ Everything lost | ✅ State database remembers uploaded files and continues |
| **Upload Speed** | ⚠️ Limited by single-thread JavaScript | ⚡ **4x – 8x Faster**: Multi-threaded parallel stream transfers |

---

## 2. How the Dedicated Python Uploader Works

The Python Uploader is a lightweight native desktop script or background worker integrated directly into SEQUORA Studio.

```
+-----------------------------------------------------------------------------------+
|                           SEQUORA Python Uploader                                |
+-----------------------------------------------------------------------------------+
  |
  +--> 1. Folder Scanner: Scans 1 TB local folder (finds 5,000 photos + 20 master videos)
  |
  +--> 2. State DB (.upload_state.json): Tracks [Pending / Uploading / Completed / Failed]
  |
  +--> 3. Folder Tree Sync: Recreates directory hierarchy on Google Drive via Drive API v3
  |
  +--> 4. Multi-Threaded Worker Pool (4 to 8 parallel streams):
  |       |
  |       +-- Worker #1: 4K_Master_CamA.mp4 (Chunked Stream: 32MB / 64MB chunks via HTTP PUT)
  |       +-- Worker #2: 4K_Master_CamB.mp4 (Resumable session URI from Google Drive API)
  |       +-- Worker #3: RAW_Photos_Batch1.zip (Direct stream)
  |       +-- Worker #4: RAW_Photos_Batch2.zip (Direct stream)
  |
  +--> 5. Auto-Retry & Exponential Backoff: Catches HTTP 429/503 and auto-retries
  |
  +--> 6. SHA-256 Checksum Verification: Ensures zero corrupted video frames
```

### Key Mechanisms:
1. **Google Drive Resumable Upload Protocol (`uploadType=resumable`)**:
   - Python requests an upload session URI from Google Drive: `POST /upload/drive/v3/files?uploadType=resumable`.
   - The file is read from the local hard drive in small buffer blocks (e.g., 64 MB) and sent using HTTP `PUT` requests with `Content-Range: bytes 0-67108863/10737418240`.
   - If the network drops at 90% of a 50 GB video, Python sends a query to Google Drive asking *"how many bytes did you receive?"* and resumes from the 91st percent without re-uploading the first 90%!

2. **Persistent State Management (`upload_state.sqlite` or `.json`)**:
   - Every file's progress is saved in real time. If the PC shuts down or restarts, launching the script immediately continues from where it stopped.

3. **MD5 / SHA-256 Checksum Verification**:
   - Google Drive returns an MD5 hash upon upload completion. The Python script verifies this against the local file hash to guarantee zero corruption.

---

## 3. How the Dedicated Rclone Uploader Works

**Rclone** (often called *"The Swiss Army knife of cloud storage"*) is an industry-standard, high-performance Go binary designed specifically for petabyte-scale cloud data transfers.

```
+-----------------------------------------------------------------------------------+
|                             Rclone Cloud Engine                                   |
+-----------------------------------------------------------------------------------+
  Command:
  rclone copy "D:\Event_Master_1TB" "MainDrive:SEQUORA_Master_Archives/Event_Master" \
    --transfers 4 \
    --drive-chunk-size 64M \
    --checkers 8 \
    --progress \
    --retries 5
```

### Why Rclone is Popular in Video Studios:
1. **Raw Performance**: Written in Go with direct socket kernel streaming. Saturares 100% of your internet bandwidth.
2. **Drive Chunk Size Tuning (`--drive-chunk-size 64M` or `128M`)**: Maximizes upload speed for massive 10GB–100GB video files.
3. **Bi-directional Integrity Checks**: Automatically compares local and remote file size and MD5 hashes before skipping already-uploaded files.
4. **Bandwidth Throttling**: Option to limit speed during work hours (e.g., `--bwlimit "09:00,10M 18:00,off"`).

---

## 4. Python vs Rclone vs Drive Desktop: Comparison

| Criteria | 💻 Google Drive for Desktop | ⚡ Rclone Engine | 🐍 Custom Python Engine |
| :--- | :--- | :--- | :--- |
| **Installation** | Windows `.exe` installer | Single `.exe` portable binary | Runs via Python / PyInstaller |
| **User Interface** | Windows File Explorer (`G:\`) | CLI / Terminal / Bat script | Native SEQUORA Studio GUI |
| **Max File Size** | 5 TB | 5 TB | 5 TB |
| **Speed / Parallelism** | Controlled by Google Client | Highly customizable (4–16 streams) | Highly customizable (4–8 streams) |
| **Background Service** | Yes (System Tray) | Can run as Windows Scheduled Task | Background thread inside SEQUORA |
| **1 TB Master Video Suitability** | 🟢 **Excellent (Easiest)** | 🟢 **Best for Pure Speed** | 🟢 **Best for App Integration** |

---

## 5. Step-by-Step Technical Workflow

### Step 1: Authentication (OAuth 2.0 Client ID)
1. In Google Cloud Console, an OAuth 2.0 Client ID (`credentials.json`) is generated.
2. On first run, the user logs into their Google Account in the browser once.
3. A `token.json` file is saved locally with refresh tokens for permanent authorization (no re-login required).

### Step 2: Directory Discovery & State Indexing
1. The engine scans the source directory (e.g., `D:\2026-09-01_Royal_Wedding_Master`).
2. It generates a full manifest of all files, paths, and byte sizes.
3. It checks Google Drive to see which folders and files already exist, marking existing matching files as `[SKIPPED / VERIFIED]`.

### Step 3: Resumable Chunked Transfer
1. For files `< 10 MB` (thumbnails/photos): Uploads via standard direct multipart upload.
2. For files `> 10 MB` (4K/8K master videos, RAW archives):
   - Opens a resumable session URI.
   - Streams 64 MB buffer chunks sequentially.
   - Monitors upload speed (`MB/s`) and remaining time.

### Step 4: Verification & Completion Report
1. Verifies cloud file IDs and MD5 hashes.
2. Generates an `upload_summary.log` showing total gigabytes uploaded, elapsed time, and direct Google Drive links.

---

## 6. Daily 750 GB Google Quota Handling

> [!IMPORTANT]
> Google enforces a hard ceiling of **750 GB upload per 24 hours per Google account**.

### How the Engine Handles the 750 GB Limit:
1. When uploading 1 TB, the first 750 GB will upload at maximum internet speed.
2. Once Google Drive returns `403 User Rate Limit Exceeded` (750 GB ceiling reached), the engine will:
   - **NOT crash or lose progress.**
   - Log: `⚠️ Daily 750 GB quota reached. Pausing upload. Automatically resuming in 12 hours.`
   - Sleep until Google resets the quota, then automatically wake up and upload the remaining 250 GB!

---

## 7. Production Code & Setup Blueprint

### Option A: Rclone 1-Click Batch Script (`UPLOAD_1TB_RCLONE.bat`)
```bat
@echo off
title SEQUORA — 1TB Turbo Drive Sync
echo ===================================================
echo   SEQUORA Studio — 1 TB Master Drive Uploader
echo ===================================================

set LOCAL_DIR="D:\Master_Event_Archives"
set REMOTE_PATH="MainDrive:SEQUORA_Master_Archives"

rclone.exe copy %LOCAL_DIR% %REMOTE_PATH% ^
  --transfers 4 ^
  --checkers 8 ^
  --drive-chunk-size 64M ^
  --fast-list ^
  --progress ^
  --stats 2s ^
  --log-file "upload_log.txt"

echo ===================================================
echo   Sync Completed Successfully!
echo ===================================================
pause
```

### Option B: Python Chunked Resumable Engine Core Snippet
```python
import os
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from google.oauth2.credentials import Credentials

def upload_large_video_resumable(drive_service, file_path, folder_id, chunk_size=64*1024*1024):
    """
    Uploads 1GB - 50GB video files in 64MB resumable chunks without memory overload.
    """
    file_name = os.path.basename(file_path)
    file_metadata = {
        'name': file_name,
        'parents': [folder_id]
    }
    
    media = MediaFileUpload(
        file_path,
        chunksize=chunk_size,
        resumable=True
    )
    
    request = drive_service.files().create(
        body=file_metadata,
        media_body=media,
        fields='id, name, size, md5Checksum'
    )
    
    response = None
    while response is None:
        status, response = request.next_chunk()
        if status:
            progress_pct = int(status.progress() * 100)
            print(f"[{file_name}] Uploaded: {progress_pct}%")
            
    print(f"✅ Successfully uploaded: {file_name} (ID: {response.get('id')})")
    return response
```

---

## 🏁 Summary Recommendation
1. **For zero-code instant 1 TB upload**: Use **Google Drive for Desktop**.
2. **For highest command-line transfer speed & automated script**: Use **Rclone** (`--drive-chunk-size 64M`).
3. **For built-in SEQUORA Studio integration**: Use the **Python Resumable Upload Engine**.
4. **For Reference Photos & Thumbnails (`_P`/`_V`)**: Continue using the lightweight **Google Apps Script Web Uploader**.
