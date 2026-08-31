// ============================================================
// qml/components/CommandPalette.qml
// Professional Desktop Command Palette (Ctrl + K)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    signal navigate(string pageKey)
    signal actionTriggered(string action)

    modal: true
    dim: true
    width: 580
    x: (parent.width - width) / 2
    y: parent.height * 0.16

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
    }

    background: Rectangle {
        radius: 8
        color: root.theme.surface
        border.color: root.theme.border_
        border.width: 1
    }

    property var commands: [
        { key: "overview",           icon: "◻",  title: "Go to Workspace Overview",       category: "Navigation" },
        { key: "photoMatcher",       icon: "📸", title: "Open Photo Remaining Matcher",  category: "Tools" },
        { key: "videoTransfer",      icon: "🎬", title: "Open Video Sequence Matcher",   category: "Tools" },
        { key: "thumbnailSeparator", icon: "🖼",  title: "Open Thumbnail Separator",      category: "Tools" },
        { key: "remainingCollector", icon: "📦", title: "Open Remaining Photos Shifter", category: "Tools" },
        { key: "googleDriveMain",    icon: "☁️", title: "Open Main Data Drive",          category: "Cloud" },
        { key: "googleDriveThumbs",  icon: "📂", title: "Open Reference Drive",          category: "Cloud" },
        { key: "reports",            icon: "📄", title: "View Historical Reports",        category: "System" },
        { key: "activity",           icon: "⏱",  title: "View Operation Activity Log",   category: "System" },
        { key: "settings",           icon: "⚙",  title: "Open Settings",                 category: "System" }
    ]

    property string filterText: ""
    property var filteredCommands: {
        if (!filterText) return commands
        var q = filterText.toLowerCase()
        return commands.filter(function(c) {
            return c.title.toLowerCase().includes(q) || c.category.toLowerCase().includes(q)
        })
    }

    onOpened: {
        filterText = ""
        searchInput.text = ""
        searchInput.forceActiveFocus()
        cmdList.currentIndex = 0
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Search Input Header
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Text {
                    text: "🔍"
                    font.pixelSize: 13
                    opacity: 0.6
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Type a command or jump to workspace..."
                    font.pixelSize: 13
                    color: root.theme.textPrimary
                    background: Item {}
                    onTextChanged: {
                        root.filterText = text
                        cmdList.currentIndex = 0
                    }
                    Keys.onDownPressed: cmdList.incrementCurrentIndex()
                    Keys.onUpPressed: cmdList.decrementCurrentIndex()
                    Keys.onEnterPressed: root.executeSelected()
                    Keys.onReturnPressed: root.executeSelected()
                }

                Rectangle {
                    height: 20
                    width: escTxt.implicitWidth + 10
                    radius: 4
                    color: root.theme.surface2
                    border.color: root.theme.border_
                    border.width: 1

                    Text {
                        id: escTxt
                        anchors.centerIn: parent
                        text: "ESC"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.theme.textMuted
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.border_
            }
        }

        // Command Results List
        ListView {
            id: cmdList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(320, count * 40 + 8)
            clip: true
            model: root.filteredCommands
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                width: ListView.view.width
                height: 40
                color: cmdList.currentIndex === index ? root.theme.surface2 : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: modelData.icon
                        font.pixelSize: 14
                    }

                    Text {
                        text: modelData.title
                        font.pixelSize: 13
                        font.weight: cmdList.currentIndex === index ? Font.DemiBold : Font.Normal
                        color: root.theme.textPrimary
                        Layout.fillWidth: true
                    }

                    Text {
                        text: modelData.category
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: root.theme.textMuted
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: cmdList.currentIndex = index
                    onClicked: {
                        cmdList.currentIndex = index
                        root.executeSelected()
                    }
                }
            }
        }

        // Footer hint
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: root.theme.surface2
            border.color: root.theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

                RowLayout {
                    spacing: 4
                    Text { text: "↑↓"; font.pixelSize: 10; color: root.theme.textMuted; font.weight: Font.Bold }
                    Text { text: "Navigate"; font.pixelSize: 10; color: root.theme.textMuted }
                }

                RowLayout {
                    spacing: 4
                    Text { text: "↵"; font.pixelSize: 11; color: root.theme.textMuted; font.weight: Font.Bold }
                    Text { text: "Open"; font.pixelSize: 10; color: root.theme.textMuted }
                }

                Item { Layout.fillWidth: true }

                Text { text: "SEQUORA Command Palette"; font.pixelSize: 10; color: root.theme.textMuted }
            }
        }
    }

    function executeSelected() {
        if (filteredCommands.length > 0 && cmdList.currentIndex >= 0 && cmdList.currentIndex < filteredCommands.length) {
            var cmd = filteredCommands[cmdList.currentIndex]
            root.close()
            if (cmd.key === "settings") {
                root.actionTriggered("settings")
            } else {
                root.navigate(cmd.key)
            }
        }
    }
}
