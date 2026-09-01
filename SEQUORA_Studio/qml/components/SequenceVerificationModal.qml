// ============================================================
// qml/components/SequenceVerificationModal.qml
// Studio-Grade Dual Thumbnail Verification Inspector with Zoom & Relinking
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    property var pairs: []
    property var photoFoldersByDate: ({})
    property int currentIndex: 0
    property string selectedDateFilter: "ALL"
    property real zoomFactor: 1.0

    signal requestRelink(var item)

    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(1040, parent ? (parent.width - 32) : 1040)
    height: Math.min(680, parent ? (parent.height - 32) : 680)
    modal: true
    dim: true
    padding: 0
    focus: true

    background: Rectangle {
        radius: 18
        color: root.theme.surface
        border.color: root.theme.border_
        border.width: 1
    }

    // Filtered pairs list based on selectedDateFilter
    property var filteredPairs: {
        var list = root.pairs || []
        if (root.selectedDateFilter !== "ALL") {
            list = list.filter(function(p) {
                return (p.dateFolderName || "") === root.selectedDateFilter
            })
        }
        return list
    }

    // Active pair object
    property var activePair: (root.filteredPairs && root.filteredPairs.length > root.currentIndex)
                             ? root.filteredPairs[root.currentIndex] : null

    // Unique Date Folders List for ComboBox
    property var uniqueDates: {
        var set = {}
        var res = ["ALL"]
        var list = root.pairs || []
        for (var i = 0; i < list.length; i++) {
            var d = list[i].dateFolderName || ""
            if (d && !set[d]) {
                set[d] = true
                res.push(d)
            }
        }
        return res
    }

    function openForPair(pairIndex, filterDate) {
        if (filterDate) root.selectedDateFilter = filterDate
        root.currentIndex = Math.max(0, pairIndex || 0)
        root.zoomFactor = 1.0
        root.open()
    }

    function nextPair() {
        if (root.currentIndex < root.filteredPairs.length - 1) {
            root.currentIndex++
        }
    }

    function prevPair() {
        if (root.currentIndex > 0) {
            root.currentIndex--
        }
    }

    // Keyboard Shortcuts
    Shortcut {
        sequence: "Left"
        enabled: root.visible
        onActivated: root.prevPair()
    }
    Shortcut {
        sequence: "Right"
        enabled: root.visible
        onActivated: root.nextPair()
    }
    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: root.close()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        // ── 1. Inspector Header ───────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Sequence Pair Inspector & Verification"
                    font.pixelSize: 18
                    font.weight: Font.Black
                    color: root.theme.textPrimary
                }
                Text {
                    text: "Verify side-by-side video frame (_V) & photo folder (_P) thumbnails. Zoom in to check details."
                    font.pixelSize: 11
                    color: root.theme.textSecondary
                }
            }

            Item { Layout.fillWidth: true }

            // Date Filter Dropdown
            ComboBox {
                id: dateCombo
                height: 32
                model: root.uniqueDates
                displayText: currentText === "ALL" ? "All Dates" : currentText
                onActivated: {
                    root.selectedDateFilter = currentText
                    root.currentIndex = 0
                }
                background: Rectangle {
                    radius: 7
                    color: root.theme.surfaceElevated
                    border.color: root.theme.border_
                    border.width: 1
                }
                contentItem: Text {
                    leftPadding: 10
                    rightPadding: 24
                    text: dateCombo.displayText
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Pair Counter Badge
            Rectangle {
                height: 30
                radius: 6
                color: root.theme.surfaceElevated
                border.color: root.theme.borderSubtle
                border.width: 1
                implicitWidth: cntRow.implicitWidth + 16

                RowLayout {
                    id: cntRow
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "Pair " + (root.filteredPairs.length > 0 ? (root.currentIndex + 1) : 0) + " of " + root.filteredPairs.length
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.family: "Consolas, monospace"
                        color: root.theme.textPrimary
                    }
                }
            }

            // Close button
            Rectangle {
                width: 28; height: 28; radius: 14
                color: clsHov.containsMouse ? root.theme.surface2 : "transparent"
                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 13; color: root.theme.textMuted }
                MouseArea {
                    id: clsHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }

        // ── 2. Dual Side-by-Side Viewport ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: root.theme.surfaceElevated
            border.color: root.theme.borderSubtle
            border.width: 1
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // ── LEFT: Video Thumbnail Card (_V.jpg) ────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 10
                    color: root.theme.surface
                    border.color: root.theme.border_
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        // Card Header
                        RowLayout {
                            Layout.fillWidth: true
                            Rectangle {
                                width: 22; height: 22; radius: 5
                                color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                                Text { anchors.centerIn: parent; text: "🎬"; font.pixelSize: 11 }
                            }
                            Text {
                                text: "VIDEO THUMBNAIL (_V.JPG)"
                                font.pixelSize: 10
                                font.weight: Font.Black
                                font.letterSpacing: 1.0
                                color: "#10B981"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: root.activePair ? (root.activePair.dateFolderName || "") : ""
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: root.theme.textMuted
                            }
                        }

                        // Image Canvas Container with Zoom
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.theme.surface2
                            clip: true

                            Item {
                                anchors.fill: parent
                                clip: true

                                Image {
                                    id: vImg
                                    anchors.centerIn: parent
                                    width: parent.width * root.zoomFactor
                                    height: parent.height * root.zoomFactor
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                    source: (root.activePair && root.activePair.videoThumbnailPath)
                                            ? ("file:///" + root.activePair.videoThumbnailPath) : ""
                                    visible: (root.activePair && root.activePair.videoThumbnailPath !== "")

                                    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                }

                                // Placeholder if no thumbnail
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    visible: !root.activePair || !root.activePair.videoThumbnailPath
                                    spacing: 4
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "🎬"; font.pixelSize: 28; opacity: 0.5 }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "No _V Thumbnail Found"
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        color: root.theme.textMuted
                                    }
                                }
                            }
                        }

                        // Info Footer
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true
                                Text {
                                    text: root.activePair ? (root.activePair.videoName || "No video selected") : "No video selected"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    font.family: "Consolas, monospace"
                                    color: root.theme.textPrimary
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: root.activePair ? (root.activePair.videoPath || "") : ""
                                    font.pixelSize: 9
                                    font.family: "Consolas, monospace"
                                    color: root.theme.textMuted
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                // ── RIGHT: Photo Thumbnail Card (_P.jpg) ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 10
                    color: root.theme.surface
                    border.color: (root.activePair && !root.activePair.isMatched) ? root.theme.danger : root.theme.border_
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        // Card Header
                        RowLayout {
                            Layout.fillWidth: true
                            Rectangle {
                                width: 22; height: 22; radius: 5
                                color: root.theme.isDark ? "#261947" : "#F3EEFC"
                                Text { anchors.centerIn: parent; text: "📸"; font.pixelSize: 11 }
                            }
                            Text {
                                text: "PHOTO SUBFOLDER THUMBNAIL (_P.JPG)"
                                font.pixelSize: 10
                                font.weight: Font.Black
                                font.letterSpacing: 1.0
                                color: "#8B5CF6"
                            }
                            Item { Layout.fillWidth: true }

                            // Relink / Change Folder Button
                            StudioButton {
                                text: "Change Link"
                                iconText: "🔗"
                                variant: "glass"
                                btnSize: "sm"
                                theme: root.theme
                                onClicked: {
                                    if (root.activePair) {
                                        root.requestRelink(root.activePair)
                                    }
                                }
                            }
                        }

                        // Image Canvas Container with Zoom
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.theme.surface2
                            clip: true

                            Item {
                                anchors.fill: parent
                                clip: true

                                Image {
                                    id: pImg
                                    anchors.centerIn: parent
                                    width: parent.width * root.zoomFactor
                                    height: parent.height * root.zoomFactor
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                    source: (root.activePair && root.activePair.photoThumbnailPath)
                                            ? ("file:///" + root.activePair.photoThumbnailPath) : ""
                                    visible: (root.activePair && root.activePair.photoThumbnailPath !== "")

                                    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                }

                                // Placeholder if no photo thumbnail or unpaired
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    visible: !root.activePair || !root.activePair.photoThumbnailPath
                                    spacing: 4
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "📸"; font.pixelSize: 28; opacity: 0.5 }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: root.activePair && root.activePair.photoFolderName ? "No _P Thumbnail Found in Subfolder" : "Unpaired Video Clip"
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        color: (root.activePair && !root.activePair.isMatched) ? root.theme.danger : root.theme.textMuted
                                    }
                                }
                            }
                        }

                        // Info Footer
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true
                                Text {
                                    text: root.activePair ? (root.activePair.photoFolderName || "(No Photo Subfolder Linked)") : "(No Photo Subfolder Linked)"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    font.family: "Consolas, monospace"
                                    color: (root.activePair && root.activePair.isMatched) ? root.theme.textPrimary : root.theme.danger
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: root.activePair ? (root.activePair.photoFolderPath || root.activePair.reason || "") : ""
                                    font.pixelSize: 9
                                    font.family: "Consolas, monospace"
                                    color: root.theme.textMuted
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── 3. Bottom Control & Navigation Bar ─────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Previous Pair Button
            StudioButton {
                text: "Previous Pair"
                iconText: "◀"
                variant: "glass"
                btnSize: "sm"
                enabled: root.currentIndex > 0
                theme: root.theme
                onClicked: root.prevPair()
            }

            Item { Layout.fillWidth: true }

            // Zoom Controls
            RowLayout {
                spacing: 8

                Text { text: "🔍 ZOOM:"; font.pixelSize: 10; font.weight: Font.Black; color: root.theme.textMuted }

                StudioButton {
                    text: "-"
                    variant: "glass"
                    btnSize: "sm"
                    theme: root.theme
                    onClicked: root.zoomFactor = Math.max(0.7, root.zoomFactor - 0.25)
                }

                Slider {
                    id: zSlider
                    width: 120
                    from: 0.7
                    to: 3.0
                    value: root.zoomFactor
                    onMoved: root.zoomFactor = value
                }

                StudioButton {
                    text: "+"
                    variant: "glass"
                    btnSize: "sm"
                    theme: root.theme
                    onClicked: root.zoomFactor = Math.min(3.0, root.zoomFactor + 0.25)
                }

                StudioButton {
                    text: Math.round(root.zoomFactor * 100) + "% (Reset)"
                    variant: "glass"
                    btnSize: "sm"
                    theme: root.theme
                    onClicked: root.zoomFactor = 1.0
                }
            }

            Item { Layout.fillWidth: true }

            // Next Pair Button
            StudioButton {
                text: "Next Pair"
                iconText: "▶"
                variant: "glass"
                btnSize: "sm"
                enabled: root.currentIndex < (root.filteredPairs.length - 1)
                theme: root.theme
                onClicked: root.nextPair()
            }
        }
    }
}
