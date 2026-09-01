// ============================================================
// qml/components/TopToolbar.qml
// Ultra-High-End Studio Top Bar (Apple Pro / Linear Standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string activePage: "overview"
    property string photoStatus: "IDLE"
    property string videoStatus: "IDLE"
    property string thumbStatus: "IDLE"
    property real zoomFactor: 1.0

    signal openSettings()
    signal openCommandPalette()
    signal toggleTheme()
    signal zoomIn()
    signal zoomOut()
    signal resetZoom()

    Layout.fillWidth: true
    height: 52
    color: root.theme.surface

    // Subtle bottom gradient border for studio depth
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: root.theme.border_
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 16
        spacing: 16

        // ── Breadcrumb & Engine Status ─────────────────────────────────────────
        RowLayout {
            spacing: 10

            // Live Engine Pulse Pill
            Rectangle {
                height: 24
                width: engRow.implicitWidth + 16
                radius: 12
                color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                border.color: root.theme.isDark ? "#10B981" : "#A7F3D0"
                border.width: 1

                RowLayout {
                    id: engRow
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 7; height: 7; radius: 3.5
                        color: root.theme.success

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.3; duration: 900; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: "STUDIO ENGINE ONLINE"
                        font.pixelSize: 9
                        font.weight: Font.ExtraBold
                        font.letterSpacing: 0.8
                        color: root.theme.success
                    }
                }
            }

            Text {
                text: "SEQUORA"
                font.pixelSize: 13
                font.weight: Font.Black
                font.letterSpacing: 1.2
                color: root.theme.textPrimary
            }

            Text {
                text: "/"
                font.pixelSize: 12
                color: root.theme.borderHover
            }

            Text {
                text: activePage === "overview"           ? "Workspace Overview"
                    : activePage === "videoTransfer"      ? "Sync Photo Video"
                    : activePage === "thumbnailSeparator" ? "Thumbnail Shifter"
                    : activePage === "photoMatcher"       ? "Photo Status Tagger"
                    : activePage === "pvSeparator"        ? "PV Separator (Photo & Video)"
                    : activePage === "remainingCollector" ? "Remaining Photos Shifter"
                    : activePage === "googleDriveMain"    ? "Main Data Drive (Cloud)"
                    : activePage === "activity"           ? "Chronological Activity Log"
                    : activePage === "excelMerger"        ? "Inventory Report Merger"
                    : "Studio Workspace"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: root.theme.textPrimary
            }
        }

        Item { Layout.fillWidth: true }

        // ── Command Palette Launcher (Ctrl + K) ────────────────────────────────
        Rectangle {
            width: 220
            height: 32
            radius: 8
            color: cmdHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
            border.color: cmdHov.containsMouse ? root.theme.accent : root.theme.border_
            border.width: 1
            scale: cmdHov.pressed ? 0.98 : (cmdHov.containsMouse ? 1.02 : 1.0)
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 8

                Text { text: "🔍"; font.pixelSize: 11; opacity: 0.7 }
                Text {
                    text: "Quick search & jump..."
                    font.pixelSize: 12
                    color: root.theme.textMuted
                    Layout.fillWidth: true
                }
                Rectangle {
                    width: 44; height: 18; radius: 4
                    color: root.theme.surface2
                    border.color: root.theme.border_
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "Ctrl K"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.family: "Consolas, monospace"
                        color: root.theme.textMuted
                    }
                }
            }

            MouseArea {
                id: cmdHov; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openCommandPalette()
            }
        }

        // ── Zoom Controls with Tactile Spring ──────────────────────────────────
        RowLayout {
            spacing: 2

            Rectangle {
                width: 28; height: 28; radius: 6
                color: zOutHov.containsMouse ? root.theme.surface2 : "transparent"
                border.color: zOutHov.containsMouse ? root.theme.border_ : "transparent"
                border.width: 1
                scale: zOutHov.pressed ? 0.92 : (zOutHov.containsMouse ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 14; font.weight: Font.Bold; color: root.theme.textSecondary }
                MouseArea {
                    id: zOutHov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomOut()
                }
            }

            Rectangle {
                height: 24
                width: zLbl.implicitWidth + 12
                radius: 6
                color: zRstHov.containsMouse ? root.theme.surface2 : "transparent"
                scale: zRstHov.pressed ? 0.92 : (zRstHov.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                Text {
                    id: zLbl
                    anchors.centerIn: parent
                    text: Math.round(root.zoomFactor * 100) + "%"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.family: "Consolas, monospace"
                    color: root.theme.textMuted
                }
                MouseArea {
                    id: zRstHov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.resetZoom()
                }
            }

            Rectangle {
                width: 28; height: 28; radius: 6
                color: zInHov.containsMouse ? root.theme.surface2 : "transparent"
                border.color: zInHov.containsMouse ? root.theme.border_ : "transparent"
                border.width: 1
                scale: zInHov.pressed ? 0.92 : (zInHov.containsMouse ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 14; font.weight: Font.Bold; color: root.theme.textSecondary }
                MouseArea {
                    id: zInHov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomIn()
                }
            }
        }

        // ── Theme Mode Toggle Button ──────────────────────────────────────────
        Rectangle {
            width: 32; height: 32; radius: 8
            color: thmHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
            border.color: thmHov.containsMouse ? root.theme.accent : root.theme.border_
            border.width: 1
            scale: thmHov.pressed ? 0.92 : (thmHov.containsMouse ? 1.10 : 1.0)
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

            Text {
                id: themeIcon
                anchors.centerIn: parent
                text: root.theme.isDark ? "☀️" : "🌙"
                font.pixelSize: 13
                rotation: thmHov.containsMouse ? 20 : 0
                Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
            }

            MouseArea {
                id: thmHov; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleTheme()
            }
        }

        // ── Settings Button ────────────────────────────────────────────────────
        Rectangle {
            width: 32; height: 32; radius: 8
            color: setHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
            border.color: setHov.containsMouse ? root.theme.accent : root.theme.border_
            border.width: 1
            scale: setHov.pressed ? 0.92 : (setHov.containsMouse ? 1.10 : 1.0)
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

            StudioIcon {
                anchors.centerIn: parent
                name: "settings"
                size: 15
                color: setHov.containsMouse ? root.theme.accent : root.theme.textSecondary
                rotation: setHov.containsMouse ? 30 : 0
                Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
            }

            MouseArea {
                id: setHov; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openSettings()
            }
        }
    }
}
