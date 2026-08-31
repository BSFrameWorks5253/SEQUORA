// ============================================================
// qml/pages/ReportsPage.qml
// Screen: Historical Operation Reports & File Exports
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    required property var theme
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null

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
                text: "Operation Reports"
                font.pixelSize: 22
                font.weight: Font.DemiBold
                color: root.theme.textPrimary
            }
            Text {
                text: "Review and export operational logs, match audits, and CSV manifests."
                font.pixelSize: 13
                color: root.theme.textSecondary
            }
        }

        // Reports Table
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: repCol.implicitHeight

            ColumnLayout {
                id: repCol
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                // Table Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 38
                    color: root.theme.surface2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text { text: "DATE"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 90 }
                        Text { text: "TOOL"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 160 }
                        Text { text: "FILES"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 80 }
                        Text { text: "RESULT"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                        Text { text: "ACTIONS"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 150 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: root.theme.border_
                    }
                }

                // Empty State
                Item {
                    visible: !(typeof activityEngine !== "undefined" && activityEngine && activityEngine.reports && activityEngine.reports.length > 0)
                    Layout.fillWidth: true
                    height: 140

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "No reports generated yet"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: root.theme.textPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "CSV reports will appear here automatically when you export reports from Photo Matcher or complete video transfers."
                            font.pixelSize: 12
                            color: root.theme.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Table Rows
                Repeater {
                    model: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.reports) ? activityEngine.reports : []

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: rHov.containsMouse ? root.theme.surface2 : "transparent"

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
                            spacing: 12

                            Text {
                                text: modelData.date || ""
                                font.pixelSize: 12
                                color: root.theme.textSecondary
                                Layout.preferredWidth: 90
                            }

                            Text {
                                text: modelData.tool || ""
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 160
                            }

                            Text {
                                text: String(modelData.files || "")
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 80
                            }

                            Text {
                                text: modelData.result || ""
                                font.pixelSize: 12
                                color: root.theme.textSecondary
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.preferredWidth: 150
                                spacing: 8

                                Rectangle {
                                    height: 26
                                    width: 80
                                    radius: 5
                                    color: viewHov.containsMouse ? root.theme.accent : root.theme.surface2
                                    border.color: root.theme.border_
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "View Report"
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        color: viewHov.containsMouse ? "#FFFFFF" : root.theme.accent
                                    }

                                    MouseArea {
                                        id: viewHov; anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            toast.show("📄 Opening report: " + modelData.path, "info")
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea { id: rHov; anchors.fill: parent; hoverEnabled: true }
                    }
                }
            }
        }

        Item { height: 20 }
    }

    ToastNotification { id: toast; theme: root.theme }
}
