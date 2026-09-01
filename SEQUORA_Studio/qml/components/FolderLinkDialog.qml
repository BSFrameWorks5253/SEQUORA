// ============================================================
// qml/components/FolderLinkDialog.qml
// Searchable folder picker for linking video clips within the date folder
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    property var videoItem: null
    property var photoFoldersByDate: ({})
    property string searchQuery: ""

    signal folderSelected(string videoPath, string photoFolderPath, string photoFolderName)

    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(520, parent ? (parent.width - 40) : 520)
    height: Math.min(560, parent ? (parent.height - 40) : 560)
    modal: true
    dim: true
    padding: 0

    background: Rectangle {
        radius: 16
        color: root.theme.surface
        border.color: root.theme.border_
        border.width: 1
    }

    // Candidate folders for the active video's date folder
    property var candidateFolders: {
        if (!root.videoItem) return []
        var dName = root.videoItem.dateFolderName || ""
        var list = []
        if (dName && root.photoFoldersByDate && root.photoFoldersByDate[dName]) {
            list = root.photoFoldersByDate[dName]
        } else if (root.photoFoldersByDate && root.photoFoldersByDate["All Folders"]) {
            list = root.photoFoldersByDate["All Folders"]
        }

        if (root.searchQuery !== "") {
            var q = root.searchQuery.toLowerCase()
            list = list.filter(function(f) {
                return (f.name || "").toLowerCase().includes(q) ||
                       (f.path || "").toLowerCase().includes(q)
            })
        }
        return list
    }

    property var selectedFolder: null

    function openForVideo(item) {
        root.videoItem = item
        root.searchQuery = ""
        root.selectedFolder = null
        root.open()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // ── Dialog Header ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 2
                Text {
                    text: "Link Video to Photo Subfolder"
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    color: root.theme.textPrimary
                }
                Text {
                    text: root.videoItem ? ("Video: " + (root.videoItem.videoName || "") + " · Date: " + (root.videoItem.dateFolderName || "Root")) : ""
                    font.pixelSize: 11
                    font.family: "Consolas, monospace"
                    color: root.theme.textSecondary
                    elide: Text.ElideMiddle
                }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 28; height: 28; radius: 14
                color: clsHov.containsMouse ? root.theme.surface2 : "transparent"
                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 12; color: root.theme.textMuted }
                MouseArea {
                    id: clsHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }

        // ── Search Field ──────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 38
            radius: 8
            color: root.theme.surfaceElevated
            border.color: sInp.activeFocus ? root.theme.accent : root.theme.border_
            border.width: sInp.activeFocus ? 1.5 : 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8
                Text { text: "🔍"; font.pixelSize: 12; opacity: 0.6 }
                TextField {
                    id: sInp
                    Layout.fillWidth: true
                    placeholderText: "Search subfolders in this date folder..."
                    font.pixelSize: 12
                    color: root.theme.textPrimary
                    background: Item {}
                    onTextChanged: root.searchQuery = text
                }
                Text {
                    visible: root.searchQuery !== ""
                    text: "✕"
                    font.pixelSize: 11
                    color: root.theme.textMuted
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { sInp.text = ""; root.searchQuery = "" }
                    }
                }
            }
        }

        // ── Folder List ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: root.theme.surfaceElevated
            border.color: root.theme.borderSubtle
            border.width: 1
            clip: true

            ListView {
                id: folderList
                anchors.fill: parent
                model: root.candidateFolders
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 42
                    color: (root.selectedFolder && root.selectedFolder.path === modelData.path)
                           ? (root.theme.isDark ? "#261947" : "#F3EEFC")
                           : (fHov.containsMouse ? root.theme.surface2 : "transparent")

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
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text { text: "📁"; font.pixelSize: 14 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: modelData.name || ""
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: (root.selectedFolder && root.selectedFolder.path === modelData.path) ? "#8B5CF6" : root.theme.textPrimary
                                elide: Text.ElideMiddle
                            }
                            Text {
                                text: modelData.path || ""
                                font.pixelSize: 9
                                font.family: "Consolas, monospace"
                                color: root.theme.textMuted
                                elide: Text.ElideMiddle
                            }
                        }

                        Text {
                            visible: root.selectedFolder && root.selectedFolder.path === modelData.path
                            text: "✓"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: "#8B5CF6"
                        }
                    }

                    MouseArea {
                        id: fHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedFolder = modelData
                        onDoubleClicked: {
                            root.selectedFolder = modelData
                            root.confirmLink()
                        }
                    }
                }

                // Empty State
                Item {
                    anchors.centerIn: parent
                    visible: root.candidateFolders.length === 0
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "No subfolders found"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: root.theme.textSecondary
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            text: "No candidate subfolders match this filter."
                            font.pixelSize: 11
                            color: root.theme.textMuted
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        // ── Action Footer ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            StudioButton {
                text: "Cancel"
                variant: "glass"
                btnSize: "sm"
                theme: root.theme
                onClicked: root.close()
            }

            StudioButton {
                text: "Link Video Clip"
                iconText: "🔗"
                variant: "primary"
                btnSize: "sm"
                enabled: root.selectedFolder !== null && root.videoItem !== null
                theme: root.theme
                onClicked: root.confirmLink()
            }
        }
    }

    function confirmLink() {
        if (root.videoItem && root.selectedFolder) {
            root.folderSelected(root.videoItem.videoPath, root.selectedFolder.path, root.selectedFolder.name)
            root.close()
        }
    }
}
