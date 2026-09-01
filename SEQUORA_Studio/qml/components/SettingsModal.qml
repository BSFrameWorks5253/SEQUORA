// ============================================================
// qml/components/SettingsModal.qml
// Glassmorphic Settings Modal with Integrated In-App Auto-Updater
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    property var engine: null
    property string updateStatusMsg: ""
    property bool hasUpdate: false
    property bool isRestartReady: false
    signal changeTheme(string t)

    modal: true
    dim: true
    width: 560
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    background: Rectangle {
        radius: 18
        color: root.theme.name === "dark" ? "#22222CEE" : "#FFFFFFF6"
        border.color: root.theme.border_
        border.width: 1.5
    }

    Connections {
        target: typeof appUpdater !== "undefined" ? appUpdater : null
        function onUpdateAvailable(newVer, notes, dlUrl) {
            root.hasUpdate = true
            root.isRestartReady = false
            root.updateStatusMsg = "New update available: v" + newVer
        }
        function onNoUpdateFound(curVer) {
            root.hasUpdate = false
            root.updateStatusMsg = "You're on the latest version (v" + curVer + ") ✓"
        }
        function onCheckError(err) {
            root.updateStatusMsg = "Check failed: " + err
        }
        function onDownloadProgress(pct, statusText) {
            root.updateStatusMsg = statusText
        }
        function onUpdateReadyToRestart(msg) {
            root.hasUpdate = false
            root.isRestartReady = true
            root.updateStatusMsg = msg
        }
        function onUpdateFailed(err) {
            root.updateStatusMsg = "Update failed: " + err
        }
    }

    contentItem: ColumnLayout {
        spacing: 16

        // Title Header
        RowLayout {
            spacing: 10
            Text { text: "⚙️"; font.pixelSize: 20 }
            Text {
                text: "Studio Preferences & Updates"
                font.pixelSize: 16
                font.weight: Font.ExtraBold
                color: theme.textPrimary
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.border_
        }

        // Theme Switcher
        RowLayout {
            spacing: 16
            Text {
                text: "Theme Palette:"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: theme.textPrimary
            }
            RadioButton {
                text: "Warm Beige"
                checked: (engine && engine.config ? engine.config["theme"] : "beige") !== "dark"
                onToggled: if (checked) root.changeTheme("beige")
            }
            RadioButton {
                text: "Dark Obsidian"
                checked: (engine && engine.config ? engine.config["theme"] : "beige") === "dark"
                onToggled: if (checked) root.changeTheme("dark")
            }
        }

        // Skip Processed Option
        CheckBox {
            text: "Skip already-processed files (_U, _R, _M)"
            checked: (engine && engine.config) ? (engine.config["skip_processed"] !== false) : true
            font.pixelSize: 13
            font.weight: Font.Bold
            Material.accent: theme.accent
            onToggled: {
                if (!engine) return
                var cfg = Object.assign({}, engine.config || {})
                cfg["skip_processed"] = checked
                engine.saveConfig(cfg)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.border_
        }

        // ── In-App Auto-Update Suite ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 10
            color: theme.surface2
            border.color: root.hasUpdate ? theme.accent : theme.border_
            border.width: root.hasUpdate ? 1.5 : 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        RowLayout {
                            spacing: 6
                            Text {
                                text: "SEQUORA Studio Release"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: theme.textPrimary
                            }
                            Rectangle {
                                height: 18
                                width: vBadgeTxt.implicitWidth + 12
                                radius: 9
                                color: theme.accentSoft
                                Text {
                                    id: vBadgeTxt
                                    anchors.centerIn: parent
                                    text: typeof appUpdater !== "undefined" && appUpdater ? "v" + appUpdater.currentVersion : "v3.0.3"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    color: theme.accent
                                }
                            }
                        }

                        Text {
                            text: root.updateStatusMsg ? root.updateStatusMsg : "Automated background update engine"
                            font.pixelSize: 11
                            color: root.hasUpdate ? theme.accent : (root.isRestartReady ? theme.success : theme.textMuted)
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    // Check for Updates Button
                    Rectangle {
                        visible: !root.hasUpdate && !root.isRestartReady && !(typeof appUpdater !== "undefined" && appUpdater && appUpdater.isDownloading)
                        width: 140
                        height: 32
                        radius: 6
                        color: btnUpdateHov.containsMouse ? theme.surfaceElevated : theme.surface
                        border.color: theme.border_
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: (typeof appUpdater !== "undefined" && appUpdater && appUpdater.isChecking) ? "Checking..." : "Check for Updates"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: theme.textPrimary
                        }

                        MouseArea {
                            id: btnUpdateHov
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                if (typeof appUpdater !== "undefined" && appUpdater) {
                                    appUpdater.checkForUpdates()
                                }
                            }
                        }
                    }

                    // Download & Install Button
                    Rectangle {
                        visible: root.hasUpdate && !(typeof appUpdater !== "undefined" && appUpdater && appUpdater.isDownloading)
                        width: 160
                        height: 32
                        radius: 6
                        color: theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: "⬇️ Download & Update"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof appUpdater !== "undefined" && appUpdater) {
                                    appUpdater.downloadAndInstallUpdate()
                                }
                            }
                        }
                    }

                    // Restart App Button
                    Rectangle {
                        visible: root.isRestartReady
                        width: 140
                        height: 32
                        radius: 6
                        color: theme.success

                        Text {
                            anchors.centerIn: parent
                            text: "🔄 Restart App"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof appReloader !== "undefined" && appReloader) {
                                    appReloader.restartApp()
                                }
                            }
                        }
                    }
                }

                // Download Progress Bar (When downloading update)
                Rectangle {
                    visible: typeof appUpdater !== "undefined" && appUpdater && appUpdater.isDownloading
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: theme.surface

                    Rectangle {
                        width: parent.width * (typeof appUpdater !== "undefined" && appUpdater ? (appUpdater.downloadPercent / 100.0) : 0)
                        height: parent.height
                        radius: 3
                        color: theme.accent
                    }
                }
            }
        }

        // Footer Actions
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Rectangle {
                width: 90
                height: 34
                radius: 8
                color: closeHover.containsMouse ? theme.surface2 : "transparent"
                border.color: closeHover.containsMouse ? theme.borderHover : theme.border_
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: theme.textPrimary
                }
                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.close()
                }
            }
        }
    }
}
