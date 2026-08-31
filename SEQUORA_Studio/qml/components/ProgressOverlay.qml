// ============================================================
// qml/components/ProgressOverlay.qml
// Professional Desktop Operation Modal (Clean Linear Progress)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property bool visible_: false
    property string title: "Processing files..."
    property string message: ""
    property string currentFile: ""
    property int currentCount: 0
    property int totalCount: 0
    property real progress: totalCount > 0 ? Math.min(1.0, currentCount / totalCount) : 0.0

    signal cancelClicked()

    visible: visible_
    anchors.fill: parent
    color: root.theme.name === "dark" ? "#00000088" : "#00000044"
    z: 9999

    // Consume mouse events
    MouseArea { anchors.fill: parent }

    Rectangle {
        width: 480
        anchors.centerIn: parent
        radius: 8
        color: root.theme.surface
        border.color: root.theme.border_
        border.width: 1
        implicitHeight: modalCol.implicitHeight + 36

        ColumnLayout {
            id: modalCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 24
            spacing: 16

            // Header
            ColumnLayout {
                spacing: 4
                Text {
                    text: root.title
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                }
                Text {
                    text: root.message || "Operation in progress, please wait..."
                    font.pixelSize: 13
                    color: root.theme.textSecondary
                }
            }

            // Linear Progress Bar
            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: root.theme.surface2
                border.color: root.theme.borderSubtle
                border.width: 1

                Rectangle {
                    width: parent.width * root.progress
                    height: parent.height
                    radius: 3
                    color: root.theme.accent

                    Behavior on width { NumberAnimation { duration: 100 } }
                }
            }

            // Stats Count & Percentage
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.totalCount > 0
                          ? (root.currentCount + " / " + root.totalCount + " files")
                          : (root.currentCount > 0 ? (root.currentCount + " items processed") : "Initializing...")
                    font.pixelSize: 12
                    font.family: "Consolas, monospace"
                    color: root.theme.textPrimary
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: Math.round(root.progress * 100) + "%"
                    font.pixelSize: 12
                    font.family: "Consolas, monospace"
                    font.weight: Font.DemiBold
                    color: root.theme.accent
                }
            }

            // Current File Box
            Rectangle {
                visible: root.currentFile !== ""
                Layout.fillWidth: true
                height: 38
                radius: 6
                color: root.theme.surfaceElevated
                border.color: root.theme.border_
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text { text: "📄"; font.pixelSize: 11; opacity: 0.7 }

                    Text {
                        text: root.currentFile
                        font.pixelSize: 11
                        font.family: "Consolas, monospace"
                        color: root.theme.textSecondary
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }

            // Cancel Button Action
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 32
                    width: cnlTxt.implicitWidth + 24
                    radius: 6
                    color: cnlHov.containsMouse ? root.theme.surface2 : "transparent"
                    border.color: root.theme.border_
                    border.width: 1

                    Text {
                        id: cnlTxt
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.theme.textPrimary
                    }

                    MouseArea {
                        id: cnlHov; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelClicked()
                    }
                }
            }
        }
    }
}
