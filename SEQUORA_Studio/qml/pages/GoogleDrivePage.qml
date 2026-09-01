// ============================================================
// qml/pages/GoogleDrivePage.qml
// Screen 6: Google Drive Multi-Account Workspaces & Download Manager
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import "../components"

Item {
    id: root
    property var engine: typeof driveEngine !== "undefined" ? driveEngine : null
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
    required property var theme
    property string activeDriveTab: "main" // "main" | "thumbnails"

    // Active Downloads Model
    ListModel {
        id: downloadsModel
    }

    function setTab(tab) {
        root.activeDriveTab = tab
    }

    function handleDownload(download) {
        var dlDir = (root.engine && root.engine.defaultDownloadPath) ? root.engine.defaultDownloadPath : ""
        if (dlDir) {
            download.downloadDirectory = dlDir
        }
        var fileName = download.downloadFileName || "downloaded_file"
        var fullPath = (download.downloadDirectory ? download.downloadDirectory + "/" : "") + fileName

        var itemIndex = downloadsModel.count
        downloadsModel.append({
            "fileName": fileName,
            "fullPath": fullPath,
            "receivedBytes": 0,
            "totalBytes": 1,
            "progress": 0.0,
            "state": "downloading", // "downloading" | "completed" | "cancelled" | "interrupted"
            "statusText": "Starting download..."
        })

        download.receivedBytesChanged.connect(function() {
            if (itemIndex < downloadsModel.count) {
                var rec = download.receivedBytes
                var tot = download.totalBytes
                var prog = tot > 0 ? (rec / tot) : 0.0
                var recMb = (rec / (1024 * 1024)).toFixed(1)
                var totMb = tot > 0 ? (tot / (1024 * 1024)).toFixed(1) : "?"
                downloadsModel.setProperty(itemIndex, "receivedBytes", rec)
                downloadsModel.setProperty(itemIndex, "totalBytes", tot)
                downloadsModel.setProperty(itemIndex, "progress", prog)
                downloadsModel.setProperty(itemIndex, "statusText", recMb + " MB / " + totMb + " MB (" + Math.round(prog * 100) + "%)")
            }
        })

        download.stateChanged.connect(function() {
            if (itemIndex < downloadsModel.count) {
                if (download.state === WebEngineDownloadRequest.DownloadCompleted) {
                    downloadsModel.setProperty(itemIndex, "state", "completed")
                    downloadsModel.setProperty(itemIndex, "progress", 1.0)
                    downloadsModel.setProperty(itemIndex, "statusText", "Completed ✓")
                    toast.show("Download complete: " + fileName, "success")
                } else if (download.state === WebEngineDownloadRequest.DownloadCancelled) {
                    downloadsModel.setProperty(itemIndex, "state", "cancelled")
                    downloadsModel.setProperty(itemIndex, "statusText", "Cancelled")
                } else if (download.state === WebEngineDownloadRequest.DownloadInterrupted) {
                    downloadsModel.setProperty(itemIndex, "state", "interrupted")
                    downloadsModel.setProperty(itemIndex, "statusText", "Interrupted: " + (download.interruptReasonString || "Network error"))
                    toast.show("Download failed: " + fileName, "error")
                }
            }
        })

        download.accept()
        downloadDrawer.visible = true
        toast.show("Downloading: " + fileName, "info")
    }

    // ── Persistent Web Profile 1: MAIN DRIVE (Account 1) ──────────────────────
    WebEngineProfile {
        id: mainDriveProfile
        storageName: "SequoraStudioDrive_Main"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        persistentStoragePath: (root.engine && root.engine.mainSessionStoragePath) ? root.engine.mainSessionStoragePath : ""
        cachePath: (root.engine && root.engine.mainSessionStoragePath) ? (root.engine.mainSessionStoragePath + "/cache") : ""
        offTheRecord: false
        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
        onDownloadRequested: function(download) {
            root.handleDownload(download)
        }
    }

    // ── Persistent Web Profile 2: REFERENCE DRIVE (Account 2 - Fully Isolated) ─
    WebEngineProfile {
        id: refDriveProfile
        storageName: "SequoraStudioDrive_Ref"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        persistentStoragePath: (root.engine && root.engine.refSessionStoragePath) ? root.engine.refSessionStoragePath : ""
        cachePath: (root.engine && root.engine.refSessionStoragePath) ? (root.engine.refSessionStoragePath + "/cache") : ""
        offTheRecord: false
        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
        onDownloadRequested: function(download) {
            root.handleDownload(download)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Workspace Bar with Dual Isolated Drive Tabs ───────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: root.theme.surface

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.border_
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Workspace Account Tabs
                RowLayout {
                    spacing: 6

                    // Tab 1: Main Drive (Account 1)
                    Rectangle {
                        height: 32
                        width: t1Txt.implicitWidth + 32
                        radius: 6
                        color: root.activeDriveTab === "main" ? root.theme.accentSoft : (t1Hov.containsMouse ? root.theme.surface2 : "transparent")
                        border.color: root.activeDriveTab === "main" ? root.theme.accent : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "☁️"; font.pixelSize: 12 }
                            Text {
                                id: t1Txt
                                text: "MAIN DRIVE (Account 1)"
                                font.pixelSize: 11
                                font.weight: root.activeDriveTab === "main" ? Font.Bold : Font.DemiBold
                                font.letterSpacing: 0.5
                                color: root.activeDriveTab === "main" ? root.theme.accent : root.theme.textSecondary
                            }
                        }

                        MouseArea {
                            id: t1Hov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true; onClicked: root.activeDriveTab = "main"
                        }
                    }

                    // Tab 2: Reference Drive (Account 2)
                    Rectangle {
                        height: 32
                        width: t2Txt.implicitWidth + 32
                        radius: 6
                        color: root.activeDriveTab === "thumbnails" ? root.theme.accentSoft : (t2Hov.containsMouse ? root.theme.surface2 : "transparent")
                        border.color: root.activeDriveTab === "thumbnails" ? root.theme.accent : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "📂"; font.pixelSize: 12 }
                            Text {
                                id: t2Txt
                                text: "REFERENCE DRIVE (Account 2)"
                                font.pixelSize: 11
                                font.weight: root.activeDriveTab === "thumbnails" ? Font.Bold : Font.DemiBold
                                font.letterSpacing: 0.5
                                color: root.activeDriveTab === "thumbnails" ? root.theme.accent : root.theme.textSecondary
                            }
                        }

                        MouseArea {
                            id: t2Hov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true; onClicked: root.activeDriveTab = "thumbnails"
                        }
                    }
                }

                // Scope badge
                Rectangle {
                    height: 24
                    width: scopeTxt.implicitWidth + 16
                    radius: 12
                    color: root.theme.surface2
                    border.color: root.theme.border_
                    border.width: 1
                    Text {
                        id: scopeTxt
                        anchors.centerIn: parent
                        text: root.activeDriveTab === "main" ? "🔒 Account 1: Master Video & RAW Archives" : "🔒 Account 2: Reference Photos & Previews"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: root.theme.textMuted
                    }
                }

                Item { Layout.fillWidth: true }

                // Downloads Toggle Button
                Rectangle {
                    width: 125
                    height: 30
                    radius: 5
                    color: downloadsModel.count > 0 ? root.theme.accentSoft : (dlHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated)
                    border.color: downloadsModel.count > 0 ? root.theme.accent : root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "📥"; font.pixelSize: 11 }
                        Text {
                            text: downloadsModel.count > 0 ? "Downloads (" + downloadsModel.count + ")" : "Downloads"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: downloadsModel.count > 0 ? root.theme.accent : root.theme.textPrimary
                        }
                    }

                    MouseArea {
                        id: dlHov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: downloadDrawer.visible = !downloadDrawer.visible
                    }
                }

                // Switch / Clear Account Session Button
                Rectangle {
                    width: 130
                    height: 30
                    radius: 5
                    color: accHov.containsMouse ? root.theme.dangerSoft : root.theme.surfaceElevated
                    border.color: root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        Text { text: "🔄"; font.pixelSize: 10 }
                        Text {
                            text: "Switch Account"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: accHov.containsMouse ? root.theme.danger : root.theme.textSecondary
                        }
                    }

                    MouseArea {
                        id: accHov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            var currentTab = root.activeDriveTab === "main" ? "main" : "thumbnails"
                            var currentView = root.activeDriveTab === "main" ? mainWebView : thumbWebView
                            currentView.url = "https://accounts.google.com/SignOutOptions"
                            toast.show("Opening Google Account Switcher...", "info")
                        }
                    }
                }

                // Open in Chrome Button
                Rectangle {
                    width: 135
                    height: 30
                    radius: 5
                    color: chrHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
                    border.color: root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "🌐"; font.pixelSize: 11 }
                        Text {
                            text: "Open in Chrome ↗"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: root.theme.textPrimary
                        }
                    }

                    MouseArea {
                        id: chrHov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            var v = root.activeDriveTab === "main" ? mainWebView : thumbWebView
                            if (root.engine) root.engine.openInExternalBrowser(v.url.toString())
                            toast.show("Opening in Google Chrome...", "info")
                        }
                    }
                }
            }
        }

        // ── Navigation & Shortcut Bar ─────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 42
            color: root.theme.surfaceElevated

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.border_
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8

                // Back
                Rectangle {
                    width: 28; height: 28; radius: 5
                    property var v: root.activeDriveTab === "main" ? mainWebView : thumbWebView
                    enabled: v ? v.canGoBack : false
                    opacity: enabled ? 1.0 : 0.4
                    color: bHov.containsMouse ? root.theme.surface : "transparent"
                    Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 13; color: root.theme.textPrimary }
                    MouseArea { id: bHov; anchors.fill: parent; hoverEnabled: true; onClicked: if (parent.enabled) parent.v.goBack() }
                }

                // Forward
                Rectangle {
                    width: 28; height: 28; radius: 5
                    property var v: root.activeDriveTab === "main" ? mainWebView : thumbWebView
                    enabled: v ? v.canGoForward : false
                    opacity: enabled ? 1.0 : 0.4
                    color: fHov.containsMouse ? root.theme.surface : "transparent"
                    Text { anchors.centerIn: parent; text: "→"; font.pixelSize: 13; color: root.theme.textPrimary }
                    MouseArea { id: fHov; anchors.fill: parent; hoverEnabled: true; onClicked: if (parent.enabled) parent.v.goForward() }
                }

                // Reload
                Rectangle {
                    width: 28; height: 28; radius: 5
                    property var v: root.activeDriveTab === "main" ? mainWebView : thumbWebView
                    color: rHov.containsMouse ? root.theme.surface : "transparent"
                    Text { anchors.centerIn: parent; text: "↻"; font.pixelSize: 14; color: root.theme.textPrimary }
                    MouseArea { id: rHov; anchors.fill: parent; hoverEnabled: true; onClicked: if (parent.v) parent.v.reload() }
                }

                // Home
                Rectangle {
                    width: 28; height: 28; radius: 5
                    color: hHov.containsMouse ? root.theme.surface : "transparent"
                    Text { anchors.centerIn: parent; text: "🏠"; font.pixelSize: 12 }
                    MouseArea {
                        id: hHov; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (root.activeDriveTab === "main") mainWebView.url = (root.engine && root.engine.mainDataUrl) ? root.engine.mainDataUrl : "https://drive.google.com/drive/my-drive"
                            else thumbWebView.url = (root.engine && root.engine.thumbnailsUrl) ? root.engine.thumbnailsUrl : "https://drive.google.com/drive/my-drive"
                        }
                    }
                }

                // Quick Drive Navigation Shortcuts
                RowLayout {
                    spacing: 4
                    Rectangle {
                        height: 26; width: 75; radius: 4
                        color: s1H.containsMouse ? root.theme.surface : "transparent"
                        Text { anchors.centerIn: parent; text: "My Drive"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textSecondary }
                        MouseArea {
                            id: s1H; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                            onClicked: {
                                var v = root.activeDriveTab === "main" ? mainWebView : thumbWebView
                                v.url = "https://drive.google.com/drive/my-drive"
                            }
                        }
                    }
                    Rectangle {
                        height: 26; width: 85; radius: 4
                        color: s2H.containsMouse ? root.theme.surface : "transparent"
                        Text { anchors.centerIn: parent; text: "Shared with me"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textSecondary }
                        MouseArea {
                            id: s2H; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                            onClicked: {
                                var v = root.activeDriveTab === "main" ? mainWebView : thumbWebView
                                v.url = "https://drive.google.com/drive/shared-with-me"
                            }
                        }
                    }
                    Rectangle {
                        height: 26; width: 60; radius: 4
                        color: s3H.containsMouse ? root.theme.surface : "transparent"
                        Text { anchors.centerIn: parent; text: "Recent"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textSecondary }
                        MouseArea {
                            id: s3H; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                            onClicked: {
                                var v = root.activeDriveTab === "main" ? mainWebView : thumbWebView
                                v.url = "https://drive.google.com/drive/recent"
                            }
                        }
                    }
                }

                // Address Input
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 5
                    color: root.theme.surface
                    border.color: urlInp.activeFocus ? root.theme.accent : root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 6

                        Text { text: "🔒"; font.pixelSize: 10; opacity: 0.6 }
                        TextInput {
                            id: urlInp
                            Layout.fillWidth: true
                            text: root.activeDriveTab === "main" ? (mainWebView.url ? mainWebView.url.toString() : "") : (thumbWebView.url ? thumbWebView.url.toString() : "")
                            font.pixelSize: 11
                            font.family: "Consolas, monospace"
                            color: root.theme.textPrimary
                            selectByMouse: true
                            clip: true
                            onAccepted: {
                                var target = text.trim()
                                if (!target.startsWith("http://") && !target.startsWith("https://")) target = "https://" + target
                                if (root.activeDriveTab === "main") mainWebView.url = target
                                else thumbWebView.url = target
                            }
                        }
                    }
                }
            }
        }

        // ── Loading Progress Indicator ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "transparent"

            Rectangle {
                property var activeView: root.activeDriveTab === "main" ? mainWebView : thumbWebView
                visible: activeView ? activeView.loading : false
                width: activeView ? (parent.width * (activeView.loadProgress / 100.0)) : 0
                height: 2
                color: root.theme.accent
            }
        }

        // ── Main Dual WebViews Container ──────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            WebEngineView {
                id: mainWebView
                profile: mainDriveProfile
                anchors.fill: parent
                visible: root.activeDriveTab === "main"
                url: (root.engine && root.engine.mainDataUrl) ? root.engine.mainDataUrl : "https://drive.google.com/drive/my-drive"
                settings.javascriptEnabled: true
                settings.pluginsEnabled: true
                settings.fullScreenSupportEnabled: true
                settings.autoLoadImages: true
                settings.localStorageEnabled: true
                settings.javascriptCanAccessClipboard: true
                settings.allowRunningInsecureContent: false
                settings.localContentCanAccessRemoteUrls: false
                settings.webGLEnabled: true
                settings.accelerated2dCanvasEnabled: true
                settings.dnsPrefetchEnabled: true
            }

            WebEngineView {
                id: thumbWebView
                profile: refDriveProfile
                anchors.fill: parent
                visible: root.activeDriveTab === "thumbnails"
                url: (root.engine && root.engine.thumbnailsUrl) ? root.engine.thumbnailsUrl : "https://drive.google.com/drive/my-drive"
                settings.javascriptEnabled: true
                settings.pluginsEnabled: true
                settings.fullScreenSupportEnabled: true
                settings.autoLoadImages: true
                settings.localStorageEnabled: true
                settings.javascriptCanAccessClipboard: true
                settings.allowRunningInsecureContent: false
                settings.localContentCanAccessRemoteUrls: false
                settings.webGLEnabled: true
                settings.accelerated2dCanvasEnabled: true
                settings.dnsPrefetchEnabled: true
            }

            // ── Floating Native Download Manager HUD (Apple Pro / Linear standard)
            Rectangle {
                id: downloadDrawer
                visible: false
                z: 1000
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 16
                anchors.rightMargin: 16
                width: 380
                height: Math.min(340, 60 + downloadsModel.count * 68)
                radius: 12
                color: root.theme.surfaceElevated
                border.color: root.theme.borderGlow
                border.width: 1.5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "📥 Downloads Manager (" + downloadsModel.count + ")"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.theme.textPrimary
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            width: 22; height: 22; radius: 11
                            color: closeDlHov.containsMouse ? root.theme.surface2 : "transparent"
                            Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 11; color: root.theme.textMuted }
                            MouseArea {
                                id: closeDlHov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                                onClicked: downloadDrawer.visible = false
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.border_ }

                    // Downloads List View
                    ListView {
                        id: dlListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: downloadsModel
                        spacing: 8

                        delegate: Rectangle {
                            width: dlListView.width
                            height: 58
                            radius: 8
                            color: root.theme.surface
                            border.color: root.theme.border_
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        text: model.state === "completed" ? "✅" : (model.state === "downloading" ? "⏳" : "⚠️")
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        text: model.fileName
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: root.theme.textPrimary
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }

                                    // Show in Folder Action Button
                                    Rectangle {
                                        visible: model.state === "completed"
                                        width: 86
                                        height: 22
                                        radius: 4
                                        color: shwHov.containsMouse ? root.theme.accentSoft : root.theme.surface2
                                        border.color: root.theme.border_
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Show in Folder"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            color: root.theme.accent
                                        }
                                        MouseArea {
                                            id: shwHov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                                            onClicked: {
                                                if (root.dialogs) root.dialogs.showInFolder(model.fullPath)
                                            }
                                        }
                                    }
                                }

                                // Progress Bar
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 4
                                    radius: 2
                                    color: root.theme.surface2

                                    Rectangle {
                                        width: parent.width * Math.min(1.0, Math.max(0.0, model.progress))
                                        height: parent.height
                                        radius: 2
                                        color: model.state === "completed" ? root.theme.success : (model.state === "interrupted" ? root.theme.danger : root.theme.accent)
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: model.statusText
                                        font.pixelSize: 9
                                        color: model.state === "completed" ? root.theme.success : root.theme.textMuted
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: (model.progress * 100).toFixed(0) + "%"
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                        color: root.theme.textSecondary
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ToastNotification { id: toast; theme: root.theme }
}
