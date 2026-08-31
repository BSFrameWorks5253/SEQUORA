// ============================================================
// qml/components/ResultsTable.qml
// Glassmorphic Results Table with Row Hover and Status Badges
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property var items: []
    property string search: ""
    property string statusFilter: "All Statuses"
    property string dateFilter: "All Dates"

    radius: 14
    color: theme.surfaceGlass
    border.color: theme.border_
    border.width: 1
    clip: true

    property var filtered: {
        return items.filter(function(item) {
            if (statusFilter !== "All Statuses" && item.status !== statusFilter) return false
            if (dateFilter !== "All Dates" && item.date_folder_name !== dateFilter) return false
            if (search) {
                var q = search.toLowerCase()
                return (item.current_filename && item.current_filename.toLowerCase().includes(q)) ||
                       (item.date_folder_name && item.date_folder_name.toLowerCase().includes(q)) ||
                       (item.proposed_new_filename && item.proposed_new_filename.toLowerCase().includes(q))
            }
            return true
        })
    }

    ListView {
        anchors.fill: parent
        clip: true
        model: root.filtered

        header: Rectangle {
            width: ListView.view.width
            height: 40
            color: root.theme.surface2
            border.color: root.theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12
                Text { text: "DATE FOLDER";        font.pixelSize: 11; font.weight: Font.ExtraBold; color: root.theme.textMuted; font.letterSpacing: 1; width: 140 }
                Text { text: "CURRENT FILENAME";   font.pixelSize: 11; font.weight: Font.ExtraBold; color: root.theme.textMuted; font.letterSpacing: 1; Layout.fillWidth: true }
                Text { text: "PROPOSED NEW NAME";  font.pixelSize: 11; font.weight: Font.ExtraBold; color: root.theme.textMuted; font.letterSpacing: 1; width: 220 }
                Text { text: "STATUS";             font.pixelSize: 11; font.weight: Font.ExtraBold; color: root.theme.textMuted; font.letterSpacing: 1; width: 120; horizontalAlignment: Text.AlignRight }
            }
        }

        delegate: Rectangle {
            id: rowBox
            width: ListView.view.width
            height: 42
            color: rowHover.containsMouse ? root.theme.purpleSoft : (index % 2 === 0 ? root.theme.surface2 : "transparent")

            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: modelData.date_folder_name || ""
                    font.pixelSize: 12
                    color: root.theme.textMuted
                    font.weight: Font.Bold
                    width: 140
                    elide: Text.ElideRight
                }

                Text {
                    text: modelData.current_filename || ""
                    Layout.fillWidth: true
                    font.pixelSize: 12
                    color: root.theme.textPrimary
                    font.weight: Font.Medium
                    elide: Text.ElideMiddle
                }

                Text {
                    text: modelData.proposed_new_filename || modelData.current_filename || ""
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: modelData.status === "Missing" ? root.theme.danger : (modelData.status === "Used" ? root.theme.success : root.theme.textPrimary)
                    width: 220
                    elide: Text.ElideMiddle
                }

                Item {
                    width: 120
                    height: 26

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 24
                        width: statusText.implicitWidth + 18
                        radius: 12
                        color: modelData.status === "Used"      ? root.theme.successSoft
                             : modelData.status === "Missing"   ? root.theme.dangerSoft
                             : modelData.status === "Duplicate" ? root.theme.warningSoft
                             : modelData.status === "Skipped"   ? root.theme.surface2
                             : root.theme.purpleSoft

                        border.color: modelData.status === "Used"      ? root.theme.success
                                    : modelData.status === "Missing"   ? root.theme.danger
                                    : modelData.status === "Duplicate" ? root.theme.warning
                                    : root.theme.border_
                        border.width: 1

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                            color: modelData.status === "Used"      ? root.theme.success
                                 : modelData.status === "Missing"   ? root.theme.danger
                                 : modelData.status === "Duplicate" ? root.theme.warning
                                 : root.theme.textMuted
                            text: (modelData.status === "Used" ? "✅ Matched (_U)"
                                 : modelData.status === "Missing" ? "⚠️ Not Matched (_R)"
                                 : modelData.status === "Duplicate" ? "🔄 Duplicate"
                                 : modelData.status === "Skipped" ? "⏭ Skipped"
                                 : modelData.status || "")
                        }
                    }
                }
            }

            MouseArea {
                id: rowHover
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }
}
