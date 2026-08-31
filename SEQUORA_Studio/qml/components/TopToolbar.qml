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
    color: root.theme.isDark ? "#141417" : "#FFFFFF"

    // Subtle bottom gradient border for studio depth
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: root.theme.border_
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: root.theme.isDark ? Qt.rgba(1.0, 1.0, 1.0, 0.04) : Qt.rgba(0.0, 0.0, 0.0, 0.02)
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
                width: engRow.implicitWidth + 14
                radius: 12
                color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                border.color: root.theme.isDark ? "#059669" : "#A7F3D0"
                border.width: 1

                RowLayout {
                    id: engRow
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 6; height: 6; radius: 3
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
                    : activePage === "photoMatcher"       ? "Photo Remaining Matcher"
                    : activePage === "videoTransfer"      ? "Video Sequence Matcher"
                    : activePage === "thumbnailSeparator" ? "Thumbnail Separator"
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
            radius: 6
            color: cmdHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
            border.color: cmdHov.containsMouse ? root.theme.accent : root.theme.border_
            border.width: 1
            scale: cmdHov.pressed ? 0.98 : (cmdHov.containsMouse ? 1.02 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100 } }

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

        // ── Zoom Controls ──────────────────────────────────────────────────────
        RowLayout {
            spacing: 2

            Rectangle {
                width: 28; height: 28; radius: 5
                color: zOutHov.containsMouse ? root.theme.surface2 : "transparent"
                border.color: zOutHov.containsMouse ? root.theme.border_ : "transparent"
                border.width: 1
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
                radius: 4
                color: zRstHov.containsMouse ? root.theme.surface2 : "transparent"
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
                width: 28; height: 28; radius: 5
                color: zInHov.containsMouse ? root.theme.surface2 : "transparent"
                border.color: zInHov.containsMouse ? root.theme.border_ : "transparent"
                border.width: 1
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
            width: 32; height: 32; radius: 6
            color: thmHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
            border.color: thmHov.containsMouse ? root.theme.accent : root.theme.border_
            border.width: 1
            scale: thmHov.pressed ? 0.94 : (thmHov.containsMouse ? 1.08 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: root.theme.isDark ? "☀️" : "🌙"
                font.pixelSize: 13
            }

            MouseArea {
                id: thmHov; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleTheme()
            }
        }

        // ── Settings Button ────────────────────────────────────────────────────
        Rectangle {
            width: 32; height: 32; radius: 6
            color: setHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
            border.color: setHov.containsMouse ? root.theme.accent : root.theme.border_
            border.width: 1
            scale: setHov.pressed ? 0.94 : (setHov.containsMouse ? 1.08 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: "⚙"
                font.pixelSize: 14
                color: setHov.containsMouse ? root.theme.accent : root.theme.textSecondary
            }

            MouseArea {
                id: setHov; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openSettings()
            }
        }
    }
}
