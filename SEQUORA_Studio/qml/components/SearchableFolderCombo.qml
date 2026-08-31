// ============================================================
// qml/components/SearchableFolderCombo.qml
// Searchable Photo Folder Picker with Live Filter and Keyboard Focus
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    property var folderList: []
    property var selectedFolder: null
    property string placeholder: "-- Select Target Photo Folder --"

    signal folderSelected(var folder)

    implicitWidth: 280
    implicitHeight: 32

    // Main Dropdown Trigger Box
    Rectangle {
        id: triggerBox
        anchors.fill: parent
        radius: 8
        color: root.theme.surface
        border.color: searchPopup.visible ? root.theme.accent : (trigHover.containsMouse ? root.theme.borderHover : root.theme.border_)
        border.width: searchPopup.visible ? 1.5 : 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 6

            Text {
                text: "📁"
                font.pixelSize: 11
            }

            Text {
                Layout.fillWidth: true
                text: root.selectedFolder ? (root.selectedFolder.name + (root.selectedFolder.dateFolderName ? (" (" + root.selectedFolder.dateFolderName + ")") : "")) : root.placeholder
                font.pixelSize: 11
                font.weight: root.selectedFolder ? Font.Bold : Font.Normal
                color: root.selectedFolder ? root.theme.textPrimary : root.theme.textMuted
                elide: Text.ElideRight
            }

            Text {
                text: searchPopup.visible ? "▲" : "▼"
                font.pixelSize: 9
                color: root.theme.textMuted
            }
        }

        MouseArea {
            id: trigHover
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                if (searchPopup.visible) {
                    searchPopup.close()
                } else {
                    searchInput.text = ""
                    searchPopup.open()
                    searchInput.forceActiveFocus()
                }
            }
        }
    }

    // Search & Filter Popup
    Popup {
        id: searchPopup
        y: triggerBox.height + 4
        width: Math.max(triggerBox.width, 360)
        height: Math.min(320, pCol.implicitHeight + 16)
        padding: 8
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            radius: 10
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1.5

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: 11
                color: "transparent"
                border.color: root.theme.accent
                border.width: 1
                opacity: 0.2
            }
        }

        contentItem: ColumnLayout {
            id: pCol
            spacing: 6

            // Search Filter Box
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 6
                color: root.theme.surface2
                border.color: searchInput.activeFocus ? root.theme.accent : root.theme.border_
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 6

                    Text { text: "🔍"; font.pixelSize: 11 }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.pixelSize: 11
                        color: root.theme.textPrimary
                        selectByMouse: true
                        clip: true

                        Text {
                            anchors.fill: parent
                            visible: !parent.text
                            text: "Type to filter folders (e.g. 12-KG, 01-Z)..."
                            font.pixelSize: 11
                            color: root.theme.textMuted
                        }
                    }

                    Rectangle {
                        visible: searchInput.text !== ""
                        width: 18
                        height: 18
                        radius: 9
                        color: root.theme.surfaceGlass
                        Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 9; color: root.theme.textMuted }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { searchInput.text = ""; searchInput.forceActiveFocus(); }
                        }
                    }
                }
            }

            // Filtered Items List
            ListView {
                id: lv
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(220, count * 34)
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds

                property var filteredModel: {
                    var list = root.folderList || []
                    var q = searchInput.text.trim().toLowerCase()
                    if (!q) return list
                    return list.filter(function(item) {
                        return (item.name && item.name.toLowerCase().indexOf(q) !== -1) ||
                               (item.dateFolderName && item.dateFolderName.toLowerCase().indexOf(q) !== -1)
                    })
                }

                model: filteredModel

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: lv.contentHeight > lv.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    width: lv.width - (lv.contentHeight > lv.height ? 12 : 0)
                    height: 32
                    radius: 6
                    color: itemHov.containsMouse
                           ? root.theme.purpleSoft
                           : (root.selectedFolder && root.selectedFolder.path === modelData.path ? root.theme.surface2 : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: "📁"
                            font.pixelSize: 11
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name || ""
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: itemHov.containsMouse ? root.theme.accent : root.theme.textPrimary
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            visible: modelData.dateFolderName !== undefined && modelData.dateFolderName !== ""
                            height: 18
                            width: dLbl.implicitWidth + 8
                            radius: 4
                            color: root.theme.surface2
                            Text {
                                id: dLbl
                                anchors.centerIn: parent
                                text: modelData.dateFolderName || ""
                                font.pixelSize: 9
                                color: root.theme.textMuted
                            }
                        }
                    }

                    MouseArea {
                        id: itemHov
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            root.selectedFolder = modelData
                            root.folderSelected(modelData)
                            searchPopup.close()
                        }
                    }
                }
            }

            // No matches found state
            Text {
                visible: lv.count === 0
                Layout.fillWidth: true
                text: "No matching photo folders found"
                font.pixelSize: 11
                color: root.theme.textMuted
                horizontalAlignment: Text.AlignHCenter
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }
        }
    }
}
