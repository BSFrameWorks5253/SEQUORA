# 🚀 Google Apps Script — Turbo Multi-Threaded Dual Uploaders

Dono Apps Script ko **Turbo Parallel Multi-Stream Engine** ke sath supercharge kar diya gaya hai:
- **⚡ 4x - 6x Parallel Multi-Streams**: Pehle 1-by-1 file upload hoti thi, ab ek sath 4 to 6 parallel streams me files simultaneously Google Drive me upload hoti hain!
- **⚡ Smart Folder ID Caching**: Baar-baar Google Drive me folder tree search nahi hota. Instant direct folder targeting se upload speed 5x-10x fast ho gayi hai.
- **📊 Live Speedometer & Real-time ETA**: Real-time Upload Speed (`MB/s` / `KB/s`), Elapsed Time, Time Remaining (ETA) aur active stream monitors.
- **Sirf Drop Box aur "Browse Folder" button**: Koi unnecessary forms ya typing nahi.
- **One-Time Path Setup**: Destination folder backend me **UserProperties** me permanently save ho jaata hai aur baar-baar poochhta nahi hai (jab tak aap pencil ✏️ icon se change na karein).
- **Reference & Remaining Photos Dual Routing**: Reference Drive uploader me aap 1-click se switch kar sakte hain:
  - **📸 Reference Photos & Thumbnails** (`_P`/`_V`)
  - **📦 Remaining Photos**
  Dono ek hi Google Drive account me apne alag-alag designated folders me upload hote hain!

---

## 📁 Files Overview

```
google_apps_scripts/
├── Main_Drive_Uploader/           <-- For Account 1 (Main Drive)
│   ├── Code.gs                    <-- Backend script with persistent UserProperties
│   ├── Index.html                 <-- Drop Box & Browse Folder UI
│   └── README.md
│
├── Reference_Drive_Uploader/      <-- For Account 2 (Reference Drive)
│   ├── Code.gs                    <-- Backend script with Dual Location Routing
│   ├── Index.html                 <-- Drop Box + 1-Click [Reference / Remaining] Switcher
│   └── README.md
│
└── DEPLOYMENT_GUIDE.md            <-- Yeh Guide
```

---

## ☁️ 1. Main Drive Uploader (Account 1)

1. Browser me apna **Main Google Account (Account 1)** open karein.
2. [script.google.com](https://script.google.com/home/start) open karein > Click **+ New Project** (`SEQUORA_Main_Drive_Uploader`).
3. `Code.gs` me [Main_Drive_Uploader/Code.gs](file:///d:/ON_GOING%20PROJECT/SEQUORA/google_apps_scripts/Main_Drive_Uploader/Code.gs) ka code paste karein.
4. **+** icon (Add file) > **HTML** > Name: `Index` > [Main_Drive_Uploader/Index.html](file:///d:/ON_GOING%20PROJECT/SEQUORA/google_apps_scripts/Main_Drive_Uploader/Index.html) ka code paste karein.
5. Click **Deploy > New deployment > Web app** (Execute as: *Me*, Who has access: *Anyone*).
6. Copy Web App URL — Ab aap kisi bhi folder ko drag-and-drop karein, sabhi files directly aapke Main Drive me chali jaayengi!

---

## 📂 2. Reference & Remaining Photos Uploader (Account 2)

1. Browser me apna **Reference Google Account (Account 2)** open karein.
2. [script.google.com](https://script.google.com/home/start) open karein > Click **+ New Project** (`SEQUORA_Reference_Drive_Uploader`).
3. `Code.gs` me [Reference_Drive_Uploader/Code.gs](file:///d:/ON_GOING%20PROJECT/SEQUORA/google_apps_scripts/Reference_Drive_Uploader/Code.gs) ka code paste karein.
4. **+** icon (Add file) > **HTML** > Name: `Index` > [Reference_Drive_Uploader/Index.html](file:///d:/ON_GOING%20PROJECT/SEQUORA/google_apps_scripts/Reference_Drive_Uploader/Index.html) ka code paste karein.
5. Click **Deploy > New deployment > Web app** (Execute as: *Me*, Who has access: *Anyone*).
6. Copy Web App URL.

### 💡 Reference Drive Usage:
- Top bar me 2 options hain:
  1. `[ 📸 Reference Photos & Thumbnails ]` -> uploads to `SEQUORA_Reference_Archives/Reference_Photos`
  2. `[ 📦 Remaining Photos ]` -> uploads to `SEQUORA_Reference_Archives/Remaining_Photos`
- Bas folder drag karein aur upload karein. Dono folders ek hi account me alag-alag jagah safely save ho jaayenge!
