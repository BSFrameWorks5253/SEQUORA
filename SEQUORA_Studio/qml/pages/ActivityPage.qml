// ============================================================
// qml/pages/ActivityPage.qml
// Screen: Chronological Studio Operation Audit Trail
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    required property var theme

    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        width: Math.min(1100, parent.width - 48)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        Item { height: 8 }

        // Header
        ColumnLayout {
            spacing: 4
            Text {
                text: "Activity Log"
                font.pixelSize: 22
                font.weight: Font.DemiBold
                color: root.theme.textPrimary
            }
            Text {
                text: "Complete audit history of file scans, sequence match operations, and transfers."
                font.pixelSize: 13
                color: root.theme.textSecondary
            }
        }

        // Activity Timeline Table
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: actCol.implicitHeight

            ColumnLayout {
                id: actCol
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                // Empty State
                Item {
                    visible: !(typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities && activityEngine.activities.length > 0)
                    Layout.fillWidth: true
                    height: 140

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "No activity recorded yet"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: root.theme.textPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "All folder indexing, batch renaming, thumbnail extractions, and video transfers will be logged here in chronological order."
                            font.pixelSize: 12
                            color: root.theme.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Repeater {
                    model: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities) ? activityEngine.activities : []

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        color: logHov.containsMouse ? root.theme.surface2 : "transparent"

                        Rectangle {
                            visible: index > 0
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: root.theme.borderSubtle
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 16

                            Text {
                                text: modelData.time || ""
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textMuted
                                Layout.preferredWidth: 85
                            }

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: modelData.color || root.theme.accent
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                RowLayout {
                                    spacing: 8
                                    Text {
                                        text: modelData.tool || ""
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        color: root.theme.textPrimary
                                    }
                                    Text {
                                        text: modelData.action ? ("— " + modelData.action) : ""
                                        font.pixelSize: 12
                                        color: root.theme.textSecondary
                                    }
                                }

                                Text {
                                    text: modelData.desc || modelData.details || ""
                                    font.pixelSize: 11
                                    color: root.theme.textMuted
                                }
                            }
                        }

                        MouseArea { id: logHov; anchors.fill: parent; hoverEnabled: true }
                    }
                }
            }
        }

        Item { height: 20 }
    }
}
