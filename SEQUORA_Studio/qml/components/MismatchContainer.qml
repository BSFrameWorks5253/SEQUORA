// ============================================================
// qml/components/MismatchContainer.qml
// Collapsible Sequence Mismatch Management Card with Photo Folder Dropdowns
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    property var model: []
    property var photoFoldersByDate: ({})
    property bool isCollapsed: false

    signal ignoreSingle(string id)
    signal ignoreAll()
    signal manualPair(var item, string targetPath)

    implicitHeight: col.implicitHeight
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        // Collapsible Header Alert Bar
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 10
            color: root.theme.dangerSoft
            border.color: root.theme.danger
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Text {
                    text: "⚠️"
                    font.pixelSize: 15
                }

                Text {
                    text: root.isCollapsed
                          ? ("Sequence Mismatches (" + root.model.length + ") — Click to Expand")
                          : ("Sequence Mismatches (" + root.model.length + ")")
                    font.pixelSize: 13
                    font.weight: Font.ExtraBold
                    color: root.theme.danger
                }

                Text {
                    visible: !root.isCollapsed
                    text: "— Unmatched clips or folders that require pairing"
                    font.pixelSize: 11
                    color: root.theme.textMuted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item {
                    visible: root.isCollapsed
                    Layout.fillWidth: true
                }

                // Dropdown Toggle Chevron Button
                Rectangle {
                    width: toggleLbl.implicitWidth + 20
                    height: 28
                    radius: 6
                    color: toggleHov.containsMouse ? root.theme.surface : "transparent"
                    border.color: root.theme.danger
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: root.isCollapsed ? "▼" : "▲"
                            font.pixelSize: 10
                            color: root.theme.danger
                        }
                        Text {
                            id: toggleLbl
                            text: root.isCollapsed ? "Expand" : "Collapse"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.theme.danger
                        }
                    }

                    MouseArea {
                        id: toggleHov
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.isCollapsed = !root.isCollapsed
                    }
                }

                // Ignore All Button
                Rectangle {
                    width: ignoreAllLbl.implicitWidth + 18
                    height: 28
                    radius: 6
                    color: ignoreAllHover.containsMouse ? root.theme.surface : "transparent"
                    border.color: root.theme.danger
                    border.width: 1

                    Text {
                        id: ignoreAllLbl
                        anchors.centerIn: parent
                        text: "Ignore All"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.theme.danger
                    }

                    MouseArea {
                        id: ignoreAllHover
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.ignoreAll()
                    }
                }
            }

            // Click entire bar to toggle collapse
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                z: -1
                cursorShape: Qt.PointingHandCursor
                onClicked: root.isCollapsed = !root.isCollapsed
            }
        }

        // Mismatch Items List (Visible when expanded)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: !root.isCollapsed

            Repeater {
                model: root.model
                delegate: Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: mRow.implicitHeight + 18
                    radius: 10
                    color: root.theme.surface
                    border.color: root.theme.border_
                    border.width: 1

                    RowLayout {
                        id: mRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 12

                        // Icon badge
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: modelData.videoName ? root.theme.purpleSoft : root.theme.dangerSoft
                            Text {
                                anchors.centerIn: parent
                                text: modelData.videoName ? "🎬" : "📸"
                                font.pixelSize: 15
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: modelData.videoName ? modelData.videoName : modelData.photoFolderName
                                    font.pixelSize: 13
                                    font.weight: Font.ExtraBold
                                    color: root.theme.textPrimary
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: modelData.dateFolderName !== undefined && modelData.dateFolderName !== ""
                                    width: dBadgeLbl.implicitWidth + 10
                                    height: 18
                                    radius: 4
                                    color: root.theme.surface2
                                    Text {
                                        id: dBadgeLbl
                                        anchors.centerIn: parent
                                        text: "📅 " + (modelData.dateFolderName || "")
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: root.theme.textMuted
                                    }
                                }
                            }

                            Text {
                                text: modelData.reason || "Unmatched item"
                                font.pixelSize: 11
                                color: root.theme.danger
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            // Manual Pair Controls with Live Searchable Picker
                            RowLayout {
                                visible: modelData.videoName !== undefined
                                spacing: 8

                                SearchableFolderCombo {
                                    id: searchCombo
                                    Layout.preferredWidth: 320
                                    theme: root.theme
                                    folderList: {
                                        var folders = (root.photoFoldersByDate && root.photoFoldersByDate[modelData.dateFolderName]) || []
                                        if (!folders || folders.length === 0) {
                                            folders = (root.photoFoldersByDate && root.photoFoldersByDate["All Folders"]) || []
                                        }
                                        return folders || []
                                    }
                                }

                                Rectangle {
                                    width: pairBtnLbl.implicitWidth + 18
                                    height: 32
                                    radius: 6
                                    color: searchCombo.selectedFolder ? root.theme.accent : root.theme.surface2
                                    opacity: searchCombo.selectedFolder ? 1.0 : 0.45

                                    Text {
                                        id: pairBtnLbl
                                        anchors.centerIn: parent
                                        text: "🔗 Pair"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: searchCombo.selectedFolder ? "white" : root.theme.textMuted
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: searchCombo.selectedFolder ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (searchCombo.selectedFolder) {
                                                root.manualPair(modelData, searchCombo.selectedFolder.path)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Ignore Single Button
                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 6
                            color: ignHover.containsMouse ? root.theme.dangerSoft : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.theme.danger
                            }

                            MouseArea {
                                id: ignHover
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.ignoreSingle(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
