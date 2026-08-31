// ============================================================
// qml/components/SettingsModal.qml
// Glassmorphic Settings Modal with Safe Event Handling
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    property var engine: null
    signal changeTheme(string t)

    modal: true
    dim: true
    width: 520
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    background: Rectangle {
        radius: 18
        color: root.theme.name === "dark" ? "#22222CEE" : "#FFFFFFF6"
        border.color: root.theme.border_
        border.width: 1.5
    }

    contentItem: ColumnLayout {
        spacing: 18

        RowLayout {
            spacing: 10
            Text { text: "⚙️"; font.pixelSize: 20 }
            Text {
                text: "Studio Preferences"
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

        // Auto-Update & Version Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Text {
                    text: "SEQUORA Studio Version"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: theme.textPrimary
                }
                Text {
                    text: typeof appUpdater !== "undefined" && appUpdater ? "Installed: v" + appUpdater.currentVersion : "v3.0.0 (Production Build)"
                    font.pixelSize: 11
                    color: theme.accent
                }
            }

            Rectangle {
                width: 140
                height: 32
                radius: 6
                color: btnUpdateHov.containsMouse ? theme.surfaceElevated : theme.surface2
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
        }

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
