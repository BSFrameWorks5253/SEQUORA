// ============================================================
// qml/pages/GoogleDrivePage.qml
// Screen 6: Google Drive Embedded Workspaces (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import "../components"

Item {
    id: root
    property var engine: typeof driveEngine !== "undefined" ? driveEngine : null
    required property var theme
    property string activeDriveTab: "main" // "main" | "thumbnails"

    function setTab(tab) {
        root.activeDriveTab = tab
    }

    // ── Persistent Web Profile (Keeps Google account logged in forever) ───────
    WebEngineProfile {
        id: persistentDriveProfile
        storageName: "SequoraStudioDriveSession"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        persistentStoragePath: (root.engine && root.engine.sessionStoragePath) ? root.engine.sessionStoragePath : ""
        cachePath: (root.engine && root.engine.sessionStoragePath) ? (root.engine.sessionStoragePath + "/cache") : ""
        offTheRecord: false
        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Workspace Bar with Dual Drive Tabs ────────────────────────────
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

                // Workspace Tabs
                RowLayout {
                    spacing: 4

                    // Tab 1: Main Drive
                    Rectangle {
                        height: 32
                        width: t1Txt.implicitWidth + 24
                        radius: 6
                        color: root.activeDriveTab === "main" ? root.theme.accentSoft : (t1Hov.containsMouse ? root.theme.surface2 : "transparent")
                        border.color: root.activeDriveTab === "main" ? root.theme.border_ : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "☁️"; font.pixelSize: 12 }
                            Text {
                                id: t1Txt
                                text: "MAIN DRIVE"
                                font.pixelSize: 11
                                font.weight: root.activeDriveTab === "main" ? Font.Bold : Font.DemiBold
                                font.letterSpacing: 0.8
                                color: root.activeDriveTab === "main" ? root.theme.accent : root.theme.textSecondary
                            }
                        }

                        MouseArea {
                            id: t1Hov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true; onClicked: root.activeDriveTab = "main"
                        }
                    }

                    // Tab 2: Reference Drive
                    Rectangle {
                        height: 32
                        width: t2Txt.implicitWidth + 24
                        radius: 6
                        color: root.activeDriveTab === "thumbnails" ? root.theme.accentSoft : (t2Hov.containsMouse ? root.theme.surface2 : "transparent")
                        border.color: root.activeDriveTab === "thumbnails" ? root.theme.border_ : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "📂"; font.pixelSize: 12 }
                            Text {
                                id: t2Txt
                                text: "REFERENCE DRIVE"
                                font.pixelSize: 11
                                font.weight: root.activeDriveTab === "thumbnails" ? Font.Bold : Font.DemiBold
                                font.letterSpacing: 0.8
                                color: root.activeDriveTab === "thumbnails" ? root.theme.accent : root.theme.textSecondary
                            }
                        }

                        MouseArea {
                            id: t2Hov; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true; onClicked: root.activeDriveTab = "thumbnails"
                        }
                    }
                }

                // Scope description
                Text {
                    text: root.activeDriveTab === "main" ? "Master videos & full photo archives" : "_P/_V thumbnails & reference photos"
                    font.pixelSize: 12
                    color: root.theme.textMuted
                    leftPadding: 8
                }

                Item { Layout.fillWidth: true }

                // Open in Chrome Button
                Rectangle {
                    width: 140
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

        // ── Navigation Bar ────────────────────────────────────────────────────
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
                    enabled: v.canGoBack
                    opacity: enabled ? 1.0 : 0.4
                    color: bHov.containsMouse ? root.theme.surface : "transparent"
                    Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 13; color: root.theme.textPrimary }
                    MouseArea { id: bHov; anchors.fill: parent; hoverEnabled: true; onClicked: if (parent.enabled) parent.v.goBack() }
                }

                // Forward
                Rectangle {
                    width: 28; height: 28; radius: 5
                    property var v: root.activeDriveTab === "main" ? mainWebView : thumbWebView
                    enabled: v.canGoForward
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
                    MouseArea { id: rHov; anchors.fill: parent; hoverEnabled: true; onClicked: parent.v.reload() }
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
                            text: root.activeDriveTab === "main" ? mainWebView.url.toString() : thumbWebView.url.toString()
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

        // ── Loading Bar ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "transparent"

            Rectangle {
                property var activeView: root.activeDriveTab === "main" ? mainWebView : thumbWebView
                visible: activeView.loading
                width: parent.width * (activeView.loadProgress / 100.0)
                height: 2
                color: root.theme.accent
            }
        }

        // ── Web Views ─────────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            WebEngineView {
                id: mainWebView
                profile: persistentDriveProfile
                anchors.fill: parent
                visible: root.activeDriveTab === "main"
                url: (root.engine && root.engine.mainDataUrl) ? root.engine.mainDataUrl : "https://drive.google.com/drive/my-drive"
                settings.javascriptEnabled: true
                settings.pluginsEnabled: true
                settings.fullScreenSupportEnabled: true
            }

            WebEngineView {
                id: thumbWebView
                profile: persistentDriveProfile
                anchors.fill: parent
                visible: root.activeDriveTab === "thumbnails"
                url: (root.engine && root.engine.thumbnailsUrl) ? root.engine.thumbnailsUrl : "https://drive.google.com/drive/my-drive"
                settings.javascriptEnabled: true
                settings.pluginsEnabled: true
                settings.fullScreenSupportEnabled: true
            }
        }
    }

    ToastNotification { id: toast; theme: root.theme }
}
