#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA — Clean JPG Extension Normalizer & Tagger Tool
===============================================================================
 Automatically normalizes compound/raw photo extensions to clean '.jpg':
   - IMG001.CR3.jpg   -> IMG001.jpg
   - IMG001.CR2.jpg   -> IMG001.jpg
   - IMG001.ARW.jpg   -> IMG001.jpg
   - IMG001.NEF.jpg   -> IMG001.jpg
   - IMG001.CR2       -> IMG001.jpg
   - IMG001.CR3       -> IMG001.jpg
   - IMG001.ARW       -> IMG001.jpg
   - PHOTO.CR3_V.jpg  -> PHOTO_V.jpg
   - PHOTO.CR3_U.jpg  -> PHOTO_U.jpg

 Features:
   - Modern Dark-Theme PySide6 GUI with Drag & Drop
   - Recursive folder & multi-file drop support
   - In-place renaming with safe collision protection
   - Real-time preview table
   - Automatic CSV Report in 'Document' folder
   - CLI execution support (python main.py <folder_or_files>)
===============================================================================
"""

import os
import sys
import re
import csv
import time
import argparse
from pathlib import Path

# Add PySide6 DLL directory for Windows Qt resolution
try:
    import PySide6
    pyside6_dir = os.path.dirname(PySide6.__file__)
    if hasattr(os, "add_dll_directory") and os.path.isdir(pyside6_dir):
        os.add_dll_directory(pyside6_dir)
    os.environ["PATH"] = pyside6_dir + os.pathsep + os.environ.get("PATH", "")
except Exception:
    pass

RAW_EXTS = {
    'cr2', 'cr3', 'nef', 'arw', 'dng', 'raf', 'orf', 'rw2', 'pef', 'srw',
    'heic', 'raw', 'jpg', 'jpeg', 'png', 'tiff', 'tif', 'bmp', 'webp'
}


def clean_filename(filename: str, target_ext: str = ".jpg") -> str:
    """
    Cleans compound/raw extensions:
    IMG001.CR3.jpg -> IMG001.jpg
    IMG001.CR2.jpg -> IMG001.jpg
    IMG001.ARW.jpg -> IMG001.jpg
    IMG001.CR2     -> IMG001.jpg
    IMG001.ARW     -> IMG001.jpg
    PHOTO.CR3_V.jpg -> PHOTO_V.jpg
    """
    name = filename.strip()

    # 1. Match compound extensions: e.g. name.CR3.jpg, name.CR2.JPG, DSC_001.NEF.jpeg
    m = re.match(r'^(?P<base>.+?)\.(?P<mid>[a-zA-Z0-9_]+)\.(?P<final>jpg|jpeg|png|webp|bmp|tif|tiff)$', name, re.IGNORECASE)
    if m:
        base = m.group('base')
        mid = m.group('mid')
        final = m.group('final')

        suffix = ''
        mid_base = mid
        if re.search(r'_[URVurv]$', mid):
            suffix = mid[-2:].upper()
            mid_base = mid[:-2]

        if mid_base.lower() in RAW_EXTS or len(mid_base) <= 5:
            out_ext = target_ext.lower() if final.lower() in ('jpg', 'jpeg') else f".{final.lower()}"
            return f"{base}{suffix}{out_ext}"

    # 2. Match raw extensions directly: e.g. IMG001.CR2 -> IMG001.jpg, IMG001.ARW -> IMG001.jpg
    stem, ext = os.path.splitext(name)
    ext_clean = ext.lstrip('.').lower()
    if ext_clean in RAW_EXTS and ext_clean not in ('jpg', 'jpeg', 'png'):
        return f"{stem}{target_ext}"

    return name


def normalize_file_in_place(file_path: str, target_ext: str = ".jpg") -> tuple[bool, str, str, str, str]:
    """
    Renames a single file in-place if its name needs normalization.
    Returns: (success, old_name, new_name, parent_folder, status_msg)
    """
    path_obj = Path(file_path)
    if not path_obj.is_file():
        return False, path_obj.name, path_obj.name, str(path_obj.parent), "Not a valid file"

    old_name = path_obj.name
    new_name = clean_filename(old_name, target_ext)

    if new_name == old_name:
        return False, old_name, old_name, str(path_obj.parent), "No change needed"

    new_path = path_obj.parent / new_name

    # Handle collision safely
    if new_path.exists() and new_path != path_obj:
        stem, ext = os.path.splitext(new_name)
        counter = 1
        while new_path.exists():
            new_name = f"{stem}_{counter}{ext}"
            new_path = path_obj.parent / new_name
            counter += 1

    try:
        path_obj.rename(new_path)
        return True, old_name, new_name, str(path_obj.parent), "Renamed Successfully"
    except Exception as e:
        return False, old_name, new_name, str(path_obj.parent), f"Error: {str(e)}"


def scan_paths(paths: list[str]) -> list[str]:
    """Recursively scans given list of files or directories for files."""
    discovered = []
    for p in paths:
        clean = os.path.abspath(p.strip().strip('"').strip("'"))
        if os.path.isdir(clean):
            for root, _, files in os.walk(clean):
                for f in files:
                    discovered.append(os.path.join(root, f))
        elif os.path.isfile(clean):
            discovered.append(clean)
    return discovered


def auto_save_report(results: list[tuple], root_dir: str = "") -> str:
    """Saves a timestamped CSV report inside a 'Document' folder."""
    try:
        base_dir = root_dir
        if not base_dir or not os.path.isdir(base_dir):
            valid_dirs = [r[3] for r in results if r[3] and os.path.isdir(r[3])]
            base_dir = os.path.commonpath(valid_dirs) if valid_dirs else os.getcwd()

        doc_dir = os.path.join(base_dir, "Document")
        os.makedirs(doc_dir, exist_ok=True)
        ts = time.strftime("%Y%m%d_%H%M%S")
        csv_path = os.path.join(doc_dir, f"Extension_Normalizer_Report_{ts}.csv")

        with open(csv_path, "w", newline="", encoding="utf-8-sig") as f:
            writer = csv.writer(f)
            writer.writerow(["SR NO", "STATUS", "ORIGINAL NAME", "NEW NAME", "FOLDER PATH", "DETAILS"])
            for idx, r in enumerate(results, 1):
                succ, old_n, new_n, p_dir, msg = r
                writer.writerow([idx, "SUCCESS" if succ else "SKIPPED", old_n, new_n, p_dir, msg])

        return csv_path
    except Exception as e:
        print(f"Failed to auto-export report: {e}")
        return ""


# =============================================================================
# PySide6 GUI Implementation
# =============================================================================
def run_gui():
    from PySide6.QtWidgets import (
        QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
        QLabel, QPushButton, QTableWidget, QTableWidgetItem, QHeaderView,
        QFileDialog, QFrame, QProgressBar, QMessageBox
    )
    from PySide6.QtCore import Qt
    from PySide6.QtGui import QColor, QFont, QDragEnterEvent, QDropEvent

    class DropZone(QFrame):
        def __init__(self, on_drop_callback, parent=None):
            super().__init__(parent)
            self.on_drop_callback = on_drop_callback
            self.setAcceptDrops(True)
            self.setObjectName("dropZone")
            self.setStyleSheet("""
                #dropZone {
                    background-color: #1A1A24;
                    border: 2px dashed #7C5CBF;
                    border-radius: 16px;
                }
                #dropZone:hover {
                    background-color: #222230;
                    border-color: #9370DB;
                }
            """)

            layout = QVBoxLayout(self)
            layout.setAlignment(Qt.AlignCenter)
            layout.setSpacing(8)

            icon_lbl = QLabel("🏷️", self)
            icon_lbl.setFont(QFont("Segoe UI Emoji", 38))
            icon_lbl.setAlignment(Qt.AlignCenter)
            layout.addWidget(icon_lbl)

            text_main = QLabel("DRAG & DROP FILES OR FOLDERS HERE", self)
            text_main.setFont(QFont("Segoe UI", 13, QFont.ExtraBold))
            text_main.setStyleSheet("color: #F5F3EF;")
            text_main.setAlignment(Qt.AlignCenter)
            layout.addWidget(text_main)

            text_sub = QLabel("Normalizes IMG001.CR3.jpg / IMG001.CR2 / IMG001.ARW ➔ IMG001.jpg in-place", self)
            text_sub.setFont(QFont("Segoe UI", 10, QFont.Bold))
            text_sub.setStyleSheet("color: #A57EED;")
            text_sub.setAlignment(Qt.AlignCenter)
            layout.addWidget(text_sub)

        def dragEnterEvent(self, event: QDragEnterEvent):
            if event.mimeData().hasUrls():
                event.acceptProposedAction()
                self.setStyleSheet("""
                    #dropZone {
                        background-color: #2D2444;
                        border: 2.5px dashed #A57EED;
                        border-radius: 16px;
                    }
                """)

        def dragLeaveEvent(self, event):
            self.setStyleSheet("""
                #dropZone {
                    background-color: #1A1A24;
                    border: 2px dashed #7C5CBF;
                    border-radius: 16px;
                }
            """)

        def dropEvent(self, event: QDropEvent):
            self.setStyleSheet("""
                #dropZone {
                    background-color: #1A1A24;
                    border: 2px dashed #7C5CBF;
                    border-radius: 16px;
                }
            """)
            paths = [u.toLocalFile() for u in event.mimeData().urls() if u.toLocalFile()]
            if paths:
                self.on_drop_callback(paths)

    class MainWindow(QMainWindow):
        def __init__(self):
            super().__init__()
            self.setWindowTitle("SEQUORA — Clean JPG Extension Normalizer & Tagger")
            self.resize(1050, 720)
            self.setMinimumSize(850, 580)
            self.setStyleSheet("""
                QMainWindow {
                    background-color: #131317;
                }
                QLabel {
                    color: #F5F3EF;
                    font-family: 'Segoe UI', sans-serif;
                }
                QTableWidget {
                    background-color: #1E1E26;
                    color: #F5F3EF;
                    gridline-color: #2E2E3A;
                    border: 1px solid #343444;
                    border-radius: 12px;
                    selection-background-color: #382A54;
                    selection-color: #FFFFFF;
                    font-family: 'Segoe UI', monospace;
                    font-size: 12px;
                }
                QHeaderView::section {
                    background-color: #282833;
                    color: #8F89A0;
                    padding: 8px;
                    font-weight: bold;
                    border: none;
                    border-bottom: 1px solid #343444;
                }
                QProgressBar {
                    border: 1px solid #343444;
                    border-radius: 6px;
                    background-color: #1E1E26;
                    text-align: center;
                    color: white;
                    font-weight: bold;
                    height: 14px;
                }
                QProgressBar::chunk {
                    background-color: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #7C5CBF, stop:1 #10B981);
                    border-radius: 5px;
                }
            """)

            self.all_results = []
            self.init_ui()

        def init_ui(self):
            central = QWidget(self)
            self.setCentralWidget(central)
            main_layout = QVBoxLayout(central)
            main_layout.setContentsMargins(24, 20, 24, 20)
            main_layout.setSpacing(16)

            # Header
            header_layout = QHBoxLayout()
            title_box = QVBoxLayout()
            title_box.setSpacing(2)

            title_lbl = QLabel("🏷️ Clean JPG Extension Normalizer", self)
            title_lbl.setFont(QFont("Segoe UI", 16, QFont.ExtraBold))
            title_lbl.setStyleSheet("color: #FFFFFF;")
            title_box.addWidget(title_lbl)

            subtitle_lbl = QLabel("Normalizes compound extensions (e.g. .CR3.jpg ➔ .jpg) and raw tags in-place instantly.", self)
            subtitle_lbl.setFont(QFont("Segoe UI", 10))
            subtitle_lbl.setStyleSheet("color: #8F89A0;")
            title_box.addWidget(subtitle_lbl)

            header_layout.addLayout(title_box)
            header_layout.addStretch()

            # Browse Buttons
            btn_browse_folder = QPushButton("📁 Browse Folder", self)
            btn_browse_folder.setFont(QFont("Segoe UI", 10, QFont.Bold))
            btn_browse_folder.setCursor(Qt.PointingHandCursor)
            btn_browse_folder.setStyleSheet("""
                QPushButton {
                    background-color: #282833;
                    color: #FFFFFF;
                    border: 1px solid #343444;
                    border-radius: 10px;
                    padding: 8px 16px;
                }
                QPushButton:hover {
                    background-color: #343444;
                    border-color: #7C5CBF;
                }
            """)
            btn_browse_folder.clicked.connect(self.browse_folder)
            header_layout.addWidget(btn_browse_folder)

            btn_browse_files = QPushButton("📄 Browse Files", self)
            btn_browse_files.setFont(QFont("Segoe UI", 10, QFont.Bold))
            btn_browse_files.setCursor(Qt.PointingHandCursor)
            btn_browse_files.setStyleSheet("""
                QPushButton {
                    background-color: #282833;
                    color: #FFFFFF;
                    border: 1px solid #343444;
                    border-radius: 10px;
                    padding: 8px 16px;
                }
                QPushButton:hover {
                    background-color: #343444;
                    border-color: #7C5CBF;
                }
            """)
            btn_browse_files.clicked.connect(self.browse_files)
            header_layout.addWidget(btn_browse_files)

            main_layout.addLayout(header_layout)

            # Drop Zone
            self.drop_zone = DropZone(self.process_paths, self)
            self.drop_zone.setFixedHeight(140)
            main_layout.addWidget(self.drop_zone)

            # Stats bar
            stats_layout = QHBoxLayout()
            self.lbl_stats = QLabel("Drop files or folders above to begin.", self)
            self.lbl_stats.setFont(QFont("Segoe UI", 10, QFont.Bold))
            self.lbl_stats.setStyleSheet("color: #8F89A0;")
            stats_layout.addWidget(self.lbl_stats)

            stats_layout.addStretch()

            self.btn_clear = QPushButton("🗑️ Clear List", self)
            self.btn_clear.setFont(QFont("Segoe UI", 9, QFont.Bold))
            self.btn_clear.setCursor(Qt.PointingHandCursor)
            self.btn_clear.setStyleSheet("""
                QPushButton {
                    background-color: transparent;
                    color: #8F89A0;
                    border: 1px solid #343444;
                    border-radius: 8px;
                    padding: 4px 12px;
                }
                QPushButton:hover {
                    color: #EF4444;
                    border-color: #EF4444;
                }
            """)
            self.btn_clear.clicked.connect(self.clear_table)
            stats_layout.addWidget(self.btn_clear)

            main_layout.addLayout(stats_layout)

            # Table of Results
            self.table = QTableWidget(self)
            self.table.setColumnCount(4)
            self.table.setHorizontalHeaderLabels(["Status", "Original Name", "New Clean Name", "Parent Folder"])
            self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
            self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.Interactive)
            self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.Interactive)
            self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.Stretch)
            self.table.setColumnWidth(1, 260)
            self.table.setColumnWidth(2, 260)
            self.table.verticalHeader().setVisible(False)
            self.table.setAlternatingRowColors(True)
            self.table.setStyleSheet(self.table.styleSheet() + """
                QTableWidget { alternate-background-color: #171720; }
            """)
            main_layout.addWidget(self.table)

            # Footer layout
            footer_layout = QHBoxLayout()
            self.progress_bar = QProgressBar(self)
            self.progress_bar.setVisible(False)
            footer_layout.addWidget(self.progress_bar)

            main_layout.addLayout(footer_layout)

        def browse_folder(self):
            folder = QFileDialog.getExistingDirectory(self, "Select Folder to Clean Extensions")
            if folder:
                self.process_paths([folder])

        def browse_files(self):
            files, _ = QFileDialog.getOpenFileNames(self, "Select Files to Clean Extensions", "", "All Files (*.*)")
            if files:
                self.process_paths(files)

        def clear_table(self):
            self.table.setRowCount(0)
            self.all_results = []
            self.lbl_stats.setText("Drop files or folders above to begin.")
            self.lbl_stats.setStyleSheet("color: #8F89A0;")

        def process_paths(self, paths: list[str]):
            all_files = scan_paths(paths)
            if not all_files:
                QMessageBox.information(self, "No Files", "No files found in dropped selection.")
                return

            self.progress_bar.setVisible(True)
            self.progress_bar.setMaximum(len(all_files))
            self.progress_bar.setValue(0)

            renamed_count = 0
            skipped_count = 0
            error_count = 0
            new_results = []

            for i, fpath in enumerate(all_files):
                succ, old_n, new_n, p_dir, msg = normalize_file_in_place(fpath, ".jpg")
                new_results.append((succ, old_n, new_n, p_dir, msg))

                if succ:
                    renamed_count += 1
                elif "Error" in msg:
                    error_count += 1
                else:
                    skipped_count += 1

                self.progress_bar.setValue(i + 1)
                QApplication.processEvents()

            self.progress_bar.setVisible(False)
            self.all_results.extend(new_results)

            # Auto-save CSV Report in Document folder
            csv_path = auto_save_report(new_results, paths[0] if len(paths) == 1 else "")

            # Populate Table
            self.table.setRowCount(len(self.all_results))
            for row_idx, r in enumerate(self.all_results):
                succ, old_n, new_n, p_dir, msg = r

                status_item = QTableWidgetItem("✅ Renamed" if succ else ("⚠️ " + msg))
                if succ:
                    status_item.setForeground(QColor("#10B981"))
                elif "Error" in msg:
                    status_item.setForeground(QColor("#EF4444"))
                else:
                    status_item.setForeground(QColor("#8F89A0"))
                status_item.setTextAlignment(Qt.AlignCenter)
                self.table.setItem(row_idx, 0, status_item)

                item_old = QTableWidgetItem(old_n)
                self.table.setItem(row_idx, 1, item_old)

                item_new = QTableWidgetItem(new_n)
                if succ:
                    item_new.setForeground(QColor("#A57EED"))
                    font = item_new.font()
                    font.setBold(True)
                    item_new.setFont(font)
                self.table.setItem(row_idx, 2, item_new)

                item_dir = QTableWidgetItem(p_dir)
                item_dir.setForeground(QColor("#8F89A0"))
                self.table.setItem(row_idx, 3, item_dir)

            self.table.scrollToBottom()

            # Update stats
            rep_msg = f" · Report saved to Document folder" if csv_path else ""
            self.lbl_stats.setText(
                f"✅ Finished: {renamed_count} files normalized & renamed | {skipped_count} skipped/unchanged | {error_count} errors{rep_msg}"
            )
            self.lbl_stats.setStyleSheet("color: #10B981; font-weight: bold;")

    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


# =============================================================================
# CLI Entry Point
# =============================================================================
def main():
    parser = argparse.ArgumentParser(description="SEQUORA — Clean JPG Extension Normalizer & Tagger Tool")
    parser.add_argument("paths", nargs="*", help="File or directory paths to process")
    parser.add_argument("--cli", action="store_true", help="Run in headless CLI mode without GUI")
    parser.add_argument("--ext", default=".jpg", help="Target clean extension (default: .jpg)")
    args = parser.parse_args()

    if args.cli or (args.paths and not sys.stdin.isatty()):
        paths = args.paths
        files = scan_paths(paths)
        print(f"[*] Scanning {len(files)} files...")
        results = []
        renamed = 0
        for f in files:
            succ, old_n, new_n, p_dir, msg = normalize_file_in_place(f, args.ext)
            results.append((succ, old_n, new_n, p_dir, msg))
            if succ:
                renamed += 1
                print(f"  [RENAMED] {old_n} -> {new_n} ({p_dir})")
            else:
                print(f"  [SKIPPED] {old_n} -> {msg}")

        csv_path = auto_save_report(results, paths[0] if paths else "")
        print(f"[+] Done! Renamed: {renamed} / {len(files)}. Report: {csv_path}")
    else:
        run_gui()


if __name__ == "__main__":
    main()
