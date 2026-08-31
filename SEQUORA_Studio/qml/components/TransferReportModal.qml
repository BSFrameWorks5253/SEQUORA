// ============================================================
// qml/components/TransferReportModal.qml
// Ultra-Premium Transfer Report — Glassmorphic + Animated
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    property var summary: null
    signal exportRequested(string format)

    modal: true
    dim: true
    width: 680
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // Smooth enter/exit
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 0.92; to: 1; duration: 280; easing.type: Easing.OutBack }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale";   from: 1; to: 0.94; duration: 200 }
        }
    }

    background: Rectangle {
        radius: 20
        color: root.theme.name === "dark" ? "#1E1E2C" : "#FFFFFF"
        border.color: root.theme.name === "dark" ? "#3D3D55" : "#E0D8CC"
        border.width: 1.5

        // Glow ring
        Rectangle {
            anchors.fill: parent; anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.color: root.theme.accent
            border.width: 1
            opacity: 0.2
            z: -1
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ── Header ──────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: 16
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.theme.accent }
                GradientStop { position: 1.0; color: root.theme.accentHover }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 18
                spacing: 14

                Text { text: "🎉"; font.pixelSize: 28 }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Transfer Complete"
                        font.pixelSize: 17
                        font.weight: Font.ExtraBold
                        color: "white"
                    }
                    Text {
                        text: root.summary ? (root.summary.totalSuccessful + " clips transferred successfully") : ""
                        font.pixelSize: 11
                        color: "#CCFFFFFF"
                    }
                }

                Item { Layout.fillWidth: true }

                // CSV path indicator
                Rectangle {
                    visible: root.summary && root.summary.autoExportedCsvPath !== ""
                    height: 28
                    width: csvLabel.implicitWidth + 20
                    radius: 8
                    color: "#22FFFFFF"
                    border.color: "#44FFFFFF"
                    border.width: 1

                    Text {
                        id: csvLabel
                        anchors.centerIn: parent
                        text: "📄 CSV Saved"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "white"
                    }
                }
            }
        }

        // ── Stats Grid ──────────────────────────────────────────────────────
        GridLayout {
            columns: 3
            columnSpacing: 12
            rowSpacing: 10
            Layout.fillWidth: true
            Layout.topMargin: 20
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            visible: root.summary !== null

            Repeater {
                model: root.summary ? [
                    { label: "Total Selected",  value: root.summary.totalClipsSelected || 0,  accent: "purple" },
                    { label: "Successful",      value: root.summary.totalSuccessful    || 0,  accent: "green"  },
                    { label: "Errors",          value: root.summary.totalErrors        || 0,  accent: "red"    },
                    { label: "Total Copied",    value: root.summary.totalBytesCopied
                                                        ? (root.summary.totalBytesCopied / 1048576).toFixed(1) + " MB" : "0 MB",
                                                accent: "blue" },
                    { label: "Duration",        value: (root.summary.durationSec || 0) + "s", accent: "orange" },
                    { label: "Avg Speed",       value: (root.summary.avgSpeedMbps || 0).toFixed(1) + " MB/s", accent: "blue" }
                ] : []

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 58
                    radius: 12
                    color: root.theme.name === "dark" ? "#28283A" : "#F8F5F0"
                    border.color: root.theme.border_
                    border.width: 1

                    // Accent top bar
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 4
                        height: 2.5
                        radius: 1.25
                        color: modelData.accent === "green"  ? root.theme.success
                             : modelData.accent === "red"    ? root.theme.danger
                             : modelData.accent === "blue"   ? root.theme.info
                             : modelData.accent === "orange" ? root.theme.warning
                             : root.theme.accent
                        opacity: 0.8
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: String(modelData.value)
                            font.pixelSize: 18
                            font.weight: Font.ExtraBold
                            color: modelData.accent === "green"  ? root.theme.success
                                 : modelData.accent === "red"    ? root.theme.danger
                                 : modelData.accent === "blue"   ? root.theme.info
                                 : modelData.accent === "orange" ? root.theme.warning
                                 : root.theme.accent
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.theme.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // CSV path display
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 4
            height: 36
            radius: 9
            color: root.theme.name === "dark" ? "#1A2A1A" : "#F0FDF4"
            border.color: root.theme.success
            border.width: 1
            visible: root.summary && root.summary.autoExportedCsvPath !== ""

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                text: "📄 CSV Report → " + (root.summary ? root.summary.autoExportedCsvPath.replace(/.*[\\\/]Document[\\\/]/, "Document/") : "")
                font.pixelSize: 11
                color: root.theme.success
                font.weight: Font.Bold
                elide: Text.ElideMiddle
            }
        }

        // ── Action Buttons ──────────────────────────────────────────────────
        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignRight
            Layout.topMargin: 14
            Layout.bottomMargin: 4
            Layout.rightMargin: 20

            // Close button
            Rectangle {
                width: 90; height: 36
                radius: 10
                color: closeArea.containsMouse ? root.theme.surface2 : "transparent"
                border.color: closeArea.containsMouse ? root.theme.borderHover : root.theme.border_
                border.width: 1
                scale: closeArea.pressed ? 0.94 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Behavior on color { ColorAnimation { duration: 140 } }

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: root.theme.textMuted
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.close()
                }
            }
        }
    }
}
