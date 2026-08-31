#!/usr/bin/env python3
"""
===============================================================================
 SEQUORA — Ultimate Native Drag & Drop '_V' Suffix Tool
===============================================================================
 Drag and drop ANY number of JPG/image files or folders from ANY location.
 Every file is renamed in-place in its original folder with '_V' suffix added.

 Examples:
   D:/FolderA/01-Q.jpg    -> D:/FolderA/01-Q_V.jpg
   E:/FolderB/15-N.jpeg   -> E:/FolderB/15-N_V.jpeg
   C:/Photos/DSC001.JPG   -> C:/Photos/DSC001_V.JPG
===============================================================================
"""

import os
import sys
from pathlib import Path

SUPPORTED_IMAGE_EXTS = {
    ".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tiff", ".tif",
    ".cr2", ".cr3", ".nef", ".arw", ".heic"
}


def add_v_suffix_to_file(file_path: str) -> tuple[bool, str, str, str]:
    """
    Renames a file in-place by appending '_V' before extension.
    Returns (success, old_name, new_name, parent_folder).
    """
    path_obj = Path(file_path)
    if not path_obj.is_file():
        return False, path_obj.name, "Not a valid file", str(path_obj.parent)

    ext = path_obj.suffix
    if ext.lower() not in SUPPORTED_IMAGE_EXTS:
        return False, path_obj.name, f"Skipped (unsupported {ext})", str(path_obj.parent)

    stem = path_obj.stem
    if stem.upper().endswith("_V") or stem.upper().endswith("-V"):
        return False, path_obj.name, "Already has _V suffix", str(path_obj.parent)

    new_filename = f"{stem}_V{ext}"
    new_path = path_obj.parent / new_filename

    if new_path.exists() and new_path != path_obj:
        counter = 1
        while new_path.exists():
            new_filename = f"{stem}_V_copy{counter}{ext}"
            new_path = path_obj.parent / new_filename
            counter += 1

    try:
        path_obj.rename(new_path)
        return True, path_obj.name, new_filename, str(path_obj.parent)
    except Exception as e:
        return False, path_obj.name, f"Error: {str(e)}", str(path_obj.parent)


def process_dropped_paths(paths: list[str]) -> list[tuple[bool, str, str, str]]:
    """
    Processes all dropped paths (files or folders).
    Recursively scans any dropped folders.
    """
    results = []
    files_to_process = []

    for p in paths:
        clean = os.path.abspath(p.strip().strip('"').strip("'"))
        if os.path.isdir(clean):
            for root, _, files in os.walk(clean):
                for f in files:
                    if Path(f).suffix.lower() in SUPPORTED_IMAGE_EXTS:
                        files_to_process.append(os.path.join(root, f))
        elif os.path.isfile(clean):
            files_to_process.append(clean)

    for fpath in files_to_process:
        succ, old_name, new_name, parent_dir = add_v_suffix_to_file(fpath)
        results.append((succ, old_name, new_name, parent_dir))

    return results


def run_qt_app():
    """Runs a modern PySide6 GUI with full native drag-and-drop support."""
    from PySide6.QtWidgets import (
        QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
        QLabel, QPushButton, QTableWidget, QTableWidgetItem, QHeaderView,
        QFileDialog, QFrame
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
                    background-color: #20202A;
                    border: 2px dashed #7C5CBF;
                    border-radius: 16px;
                }
                #dropZone:hover {
                    background-color: #282836;
                    border-color: #9370DB;
                }
            """)

            layout = QVBoxLayout(self)
            layout.setAlignment(Qt.AlignCenter)
            layout.setSpacing(8)

            icon_lbl = QLabel("📥", self)
            icon_lbl.setFont(QFont("Segoe UI Emoji", 36))
            icon_lbl.setAlignment(Qt.AlignCenter)
            layout.addWidget(icon_lbl)

            text_main = QLabel("DRAG & DROP JPG FILES OR FOLDERS HERE", self)
            text_main.setFont(QFont("Segoe UI", 13, QFont.ExtraBold))
            text_main.setStyleSheet("color: #FFFFFF;")
            text_main.setAlignment(Qt.AlignCenter)
            layout.addWidget(text_main)

            text_sub = QLabel("Drop N files from ANY folder — each file will be renamed in-place with '_V' suffix", self)
            text_sub.setFont(QFont("Segoe UI", 10))
            text_sub.setStyleSheet("color: #8F89A0;")
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
                    background-color: #20202A;
                    border: 2px dashed #7C5CBF;
                    border-radius: 16px;
                }
            """)

        def dropEvent(self, event: QDropEvent):
            self.setStyleSheet("""
                #dropZone {
                    background-color: #20202A;
                    border: 2px dashed #7C5CBF;
                    border-radius: 16px;
                }
            """)
            urls = event.mimeData().urls()
            paths = [url.toLocalFile() for url in urls if url.isLocalFile()]
            if paths:
                self.on_drop_callback(paths)

    class RenamerWindow(QMainWindow):
        def __init__(self):
            super().__init__()
            self.setWindowTitle("SEQUORA — Drag & Drop '_V' Suffix Renamer")
            self.resize(880, 640)
            self.setStyleSheet("""
                QMainWindow { background-color: #131317; }
                QLabel { color: #F5F3EF; }
                QTableWidget {
                    background-color: #1E1E26;
                    border: 1px solid #343444;
                    border-radius: 10px;
                    gridline-color: #2A2A38;
                    color: #E2E2EA;
                    font-family: 'Consolas', 'Segoe UI';
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
                QPushButton {
                    background-color: #7C5CBF;
                    color: white;
                    font-weight: bold;
                    border-radius: 8px;
                    padding: 8px 16px;
                    font-size: 12px;
                }
                QPushButton:hover { background-color: #9370DB; }
                QPushButton:pressed { background-color: #6949A8; }
            """)

            central = QWidget(self)
            self.setCentralWidget(central)
            main_layout = QVBoxLayout(central)
            main_layout.setContentsMargins(24, 20, 24, 20)
            main_layout.setSpacing(14)

            # Top Header Bar
            header = QHBoxLayout()
            title_lbl = QLabel("🎬 Instant '_V' Suffix Renamer", self)
            title_lbl.setFont(QFont("Segoe UI", 16, QFont.Bold))
            header.addWidget(title_lbl)
            header.addStretch()

            btn_browse_files = QPushButton("📁 Browse Files...", self)
            btn_browse_files.clicked.connect(self.browse_files)
            header.addWidget(btn_browse_files)

            btn_browse_folder = QPushButton("📂 Browse Folder...", self)
            btn_browse_folder.setStyleSheet("background-color: #2A2A38; border: 1px solid #343444;")
            btn_browse_folder.clicked.connect(self.browse_folder)
            header.addWidget(btn_browse_folder)

            main_layout.addLayout(header)

            # Drag & Drop Zone
            self.drop_zone = DropZone(self.handle_paths, self)
            self.drop_zone.setFixedHeight(150)
            main_layout.addWidget(self.drop_zone)

            # Status Banner
            self.status_lbl = QLabel("Ready. Drag and drop any files or folders above.", self)
            self.status_lbl.setFont(QFont("Segoe UI", 11, QFont.Bold))
            self.status_lbl.setStyleSheet("color: #10B981;")
            main_layout.addWidget(self.status_lbl)

            # Results Table
            self.table = QTableWidget(0, 4, self)
            self.table.setHorizontalHeaderLabels(["Status", "Original Filename", "Renamed Filename (_V)", "Saved Location"])
            self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
            self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeToContents)
            self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeToContents)
            self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.Stretch)
            self.table.verticalHeader().setVisible(False)
            main_layout.addWidget(self.table)

        def browse_files(self):
            files, _ = QFileDialog.getOpenFileNames(self, "Select JPG / Image Files to rename with _V", "", "Images (*.jpg *.jpeg *.png *.webp *.cr2 *.cr3 *.arw);;All Files (*.*)")
            if files:
                self.handle_paths(files)

        def browse_folder(self):
            folder = QFileDialog.getExistingDirectory(self, "Select Folder to scan recursively and rename images with _V")
            if folder:
                self.handle_paths([folder])

        def handle_paths(self, paths: list[str]):
            results = process_dropped_paths(paths)
            if not results:
                self.status_lbl.setText("[-] No image files found in dropped selection.")
                self.status_lbl.setStyleSheet("color: #EF4444;")
                return

            succ_count = sum(1 for r in results if r[0])
            skip_count = len(results) - succ_count

            self.status_lbl.setText(f"✅ Successfully renamed {succ_count} file(s) with '_V' in-place! (Skipped: {skip_count})")
            self.status_lbl.setStyleSheet("color: #10B981;")

            for succ, old_name, new_name, parent_dir in results:
                row = self.table.rowCount()
                self.table.insertRow(row)

                status_item = QTableWidgetItem("✅ RENAMED" if succ else "⏭ SKIPPED")
                status_item.setForeground(QColor("#10B981" if succ else "#F59E0B"))
                status_item.setTextAlignment(Qt.AlignCenter)

                old_item = QTableWidgetItem(old_name)
                new_item = QTableWidgetItem(new_name if succ else "—")
                new_item.setForeground(QColor("#A57EED" if succ else "#8F89A0"))
                new_item.setFont(QFont("Consolas", 10, QFont.Bold))

                path_item = QTableWidgetItem(parent_dir)
                path_item.setForeground(QColor("#8F89A0"))

                self.table.setItem(row, 0, status_item)
                self.table.setItem(row, 1, old_item)
                self.table.setItem(row, 2, new_item)
                self.table.setItem(row, 3, path_item)

            self.table.scrollToBottom()

    app = QApplication(sys.argv)
    app.setStyle("Fusion")
    win = RenamerWindow()
    win.show()
    sys.exit(app.exec())


def main():
    if len(sys.argv) > 1:
        paths = sys.argv[1:]
        print(f"[*] Processing {len(paths)} dropped item(s)...")
        results = process_dropped_paths(paths)
        succ = sum(1 for r in results if r[0])
        print(f"[+] Renamed {succ} / {len(results)} files with '_V' in-place.")
        for s, old, new_n, p_dir in results:
            print(f"  {'[OK]' if s else '[--]'} {old} -> {new_n}  in  {p_dir}")
        print("\nPress Enter to exit...")
        try:
            input()
        except Exception:
            pass
    else:
        run_qt_app()


if __name__ == "__main__":
    main()