// ============================================================
// qml/components/ThumbnailCompareModal.qml
// Ultra-Modern Side-by-Side Video & Photo Thumbnail Zoom & Verify Modal
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Popup {
    id: root
    required property var theme
    property var clipList: []
    property int currentIndex: 0

    property var currentClip: (clipList && clipList.length > 0 && currentIndex >= 0 && currentIndex < clipList.length)
                              ? clipList[currentIndex] : null

    property real zoomLevel: 1.0

    signal verified(var clip)

    modal: true
    focus: true
    dim: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    anchors.centerIn: Overlay.overlay
    width: Math.min(Overlay.overlay ? (Overlay.overlay.width - 48) : 1100, 1200)
    height: Math.min(Overlay.overlay ? (Overlay.overlay.height - 48) : 750, 800)
    padding: 0

    background: Rectangle {
        radius: 18
        color: root.theme.name === "dark" ? "#1B1B26F8" : "#FFFFFFF8"
        border.color: root.theme.border_
        border.width: 1.5

        // Outer glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 19
            color: "transparent"
            border.color: root.theme.accent
            border.width: 1
            opacity: 0.3
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ── TOP HEADER BAR ────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: root.theme.surfaceGlass
            border.color: root.theme.border_
            border.width: 1
            radius: 18

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 10
                    color: root.theme.purpleSoft
                    border.color: root.theme.accent
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "🔍"
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    spacing: 2
                    RowLayout {
                        spacing: 8
                        Text {
                            text: "Thumbnail Verification & Side-by-Side Inspection"
                            font.pixelSize: 14
                            font.weight: Font.ExtraBold
                            color: root.theme.textPrimary
                        }
                        Rectangle {
                            visible: root.currentClip !== null
                            width: seqLbl.implicitWidth + 12
                            height: 20
                            radius: 6
                            color: root.theme.accent
                            Text {
                                id: seqLbl
                                anchors.centerIn: parent
                                text: "Seq " + (root.currentClip ? (root.currentClip.sequence || "—") : "")
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: "white"
                            }
                        }
                    }
                    Text {
                        text: root.currentClip
                              ? ("Clip " + (root.currentIndex + 1) + " of " + root.clipList.length + " · " + (root.currentClip.videoName || "") + " ➜ " + (root.currentClip.photoFolderName || ""))
                              : "No clip selected"
                        font.pixelSize: 11
                        color: root.theme.textMuted
                    }
                }

                Item { Layout.fillWidth: true }

                // Zoom Level Indicator Pill
                Rectangle {
                    width: 90
                    height: 32
                    radius: 8
                    color: root.theme.surface2
                    border.color: root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "🔎"; font.pixelSize: 11 }
                        Text {
                            text: Math.round(root.zoomLevel * 100) + "%"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.theme.textPrimary
                        }
                    }
                }

                // Close button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: closeHov.containsMouse ? root.theme.dangerSoft : root.theme.surface2
                    border.color: closeHov.containsMouse ? root.theme.danger : "transparent"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: closeHov.containsMouse ? root.theme.danger : root.theme.textMuted
                    }

                    MouseArea {
                        id: closeHov
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.close()
                    }
                }
            }
        }

        // ── CENTER SIDE-BY-SIDE VIEWPORT ──────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 14
            spacing: 14

            // ── LEFT: VIDEO THUMBNAIL (_V.jpg) ───────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: root.theme.surface2
                border.color: root.theme.border_
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Title Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: root.theme.purpleSoft
                            Text { anchors.centerIn: parent; text: "🎬"; font.pixelSize: 12 }
                        }
                        Text {
                            text: "Video Clip Thumbnail (_V.jpg)"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.theme.accent
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.currentClip ? (root.currentClip.videoThumbnailName || "No thumbnail") : ""
                            font.pixelSize: 10
                            color: root.theme.textMuted
                            elide: Text.ElideMiddle
                        }
                    }

                    // Zoomable Image Canvas
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: "#08080C"
                        clip: true

                        Flickable {
                            id: vFlick
                            anchors.fill: parent
                            contentWidth: vImg.width * root.zoomLevel
                            contentHeight: vImg.height * root.zoomLevel
                            boundsBehavior: Flickable.StopAtBounds

                            Image {
                                id: vImg
                                anchors.centerIn: parent
                                width: Math.min(vFlick.width, 600)
                                height: Math.min(vFlick.height, 450)
                                scale: root.zoomLevel
                                fillMode: Image.PreserveAspectFit
                                source: (root.currentClip && root.currentClip.videoThumbnailPath)
                                        ? ("file:///" + root.currentClip.videoThumbnailPath.replace(/\\/g, '/'))
                                        : ""
                                asynchronous: true
                                cache: false
                                mipmap: true
                                smooth: true

                                Behavior on scale { NumberAnimation { duration: 120 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                scrollGestureEnabled: true
                                onWheel: (wheel) => {
                                    if (wheel.angleDelta.y > 0) {
                                        root.zoomLevel = Math.min(4.0, root.zoomLevel + 0.25)
                                    } else {
                                        root.zoomLevel = Math.max(0.75, root.zoomLevel - 0.25)
                                    }
                                }
                                onDoubleClicked: root.zoomLevel = (root.zoomLevel === 1.0 ? 2.0 : 1.0)
                            }
                        }

                        // Empty State Placeholder
                        Text {
                            anchors.centerIn: parent
                            visible: !root.currentClip || !root.currentClip.videoThumbnailPath
                            text: "No Video Thumbnail Found"
                            font.pixelSize: 13
                            color: "#666677"
                        }
                    }
                }
            }

            // ── RIGHT: PHOTO THUMBNAIL (_P.jpg or sample) ─────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: root.theme.surface2
                border.color: root.theme.border_
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Title Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: root.theme.successSoft
                            Text { anchors.centerIn: parent; text: "📸"; font.pixelSize: 12 }
                        }
                        Text {
                            text: "Target Photo Thumbnail (_P.jpg)"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.theme.success
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.currentClip ? (root.currentClip.photoThumbnailName || "No thumbnail") : ""
                            font.pixelSize: 10
                            color: root.theme.textMuted
                            elide: Text.ElideMiddle
                        }
                    }

                    // Zoomable Image Canvas
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: "#08080C"
                        clip: true

                        Flickable {
                            id: pFlick
                            anchors.fill: parent
                            contentWidth: pImg.width * root.zoomLevel
                            contentHeight: pImg.height * root.zoomLevel
                            boundsBehavior: Flickable.StopAtBounds

                            Image {
                                id: pImg
                                anchors.centerIn: parent
                                width: Math.min(pFlick.width, 600)
                                height: Math.min(pFlick.height, 450)
                                scale: root.zoomLevel
                                fillMode: Image.PreserveAspectFit
                                source: (root.currentClip && root.currentClip.photoThumbnailPath)
                                        ? ("file:///" + root.currentClip.photoThumbnailPath.replace(/\\/g, '/'))
                                        : ""
                                asynchronous: true
                                cache: false
                                mipmap: true
                                smooth: true

                                Behavior on scale { NumberAnimation { duration: 120 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                scrollGestureEnabled: true
                                onWheel: (wheel) => {
                                    if (wheel.angleDelta.y > 0) {
                                        root.zoomLevel = Math.min(4.0, root.zoomLevel + 0.25)
                                    } else {
                                        root.zoomLevel = Math.max(0.75, root.zoomLevel - 0.25)
                                    }
                                }
                                onDoubleClicked: root.zoomLevel = (root.zoomLevel === 1.0 ? 2.0 : 1.0)
                            }
                        }

                        // Empty State Placeholder
                        Text {
                            anchors.centerIn: parent
                            visible: !root.currentClip || !root.currentClip.photoThumbnailPath
                            text: "No Photo Thumbnail Found"
                            font.pixelSize: 13
                            color: "#666677"
                        }
                    }
                }
            }
        }

        // ── BOTTOM CONTROLS & NAVIGATION BAR ──────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: root.theme.surfaceGlass
            border.color: root.theme.border_
            border.width: 1
            radius: 18

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 12

                // Previous Clip Button
                Rectangle {
                    width: prevLbl.implicitWidth + 24
                    height: 38
                    radius: 8
                    color: prevHov.containsMouse ? root.theme.surface2 : root.theme.surface
                    border.color: root.theme.border_
                    border.width: 1
                    opacity: root.currentIndex > 0 ? 1.0 : 0.45

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "◀"; font.pixelSize: 11; color: root.theme.textPrimary }
                        Text {
                            id: prevLbl
                            text: "Previous Clip"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.theme.textPrimary
                        }
                    }

                    MouseArea {
                        id: prevHov
                        anchors.fill: parent
                        cursorShape: root.currentIndex > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        onClicked: if (root.currentIndex > 0) root.currentIndex--
                    }
                }

                // Next Clip Button
                Rectangle {
                    width: nextLbl.implicitWidth + 24
                    height: 38
                    radius: 8
                    color: nextHov.containsMouse ? root.theme.surface2 : root.theme.surface
                    border.color: root.theme.border_
                    border.width: 1
                    opacity: root.currentIndex < (root.clipList.length - 1) ? 1.0 : 0.45

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            id: nextLbl
                            text: "Next Clip"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.theme.textPrimary
                        }
                        Text { text: "▶"; font.pixelSize: 11; color: root.theme.textPrimary }
                    }

                    MouseArea {
                        id: nextHov
                        anchors.fill: parent
                        cursorShape: root.currentIndex < (root.clipList.length - 1) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        onClicked: if (root.currentIndex < (root.clipList.length - 1)) root.currentIndex++
                    }
                }

                Item { Layout.fillWidth: true }

                // Zoom Control Buttons
                RowLayout {
                    spacing: 6

                    Rectangle {
                        width: 34
                        height: 34
                        radius: 8
                        color: zOutHov.containsMouse ? root.theme.surface2 : root.theme.surface
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 16; font.weight: Font.Bold; color: root.theme.textPrimary }
                        MouseArea {
                            id: zOutHov
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.zoomLevel = Math.max(0.75, root.zoomLevel - 0.25)
                        }
                    }

                    Rectangle {
                        width: 70
                        height: 34
                        radius: 8
                        color: zResHov.containsMouse ? root.theme.surface2 : root.theme.surface
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "Reset"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.textPrimary }
                        MouseArea {
                            id: zResHov
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.zoomLevel = 1.0
                        }
                    }

                    Rectangle {
                        width: 34
                        height: 34
                        radius: 8
                        color: zInHov.containsMouse ? root.theme.surface2 : root.theme.surface
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 16; font.weight: Font.Bold; color: root.theme.textPrimary }
                        MouseArea {
                            id: zInHov
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.zoomLevel = Math.min(4.0, root.zoomLevel + 0.25)
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Verified / Approve Button
                Rectangle {
                    width: okLbl.implicitWidth + 28
                    height: 38
                    radius: 8
                    color: root.theme.success

                    scale: okHov.pressed ? 0.96 : (okHov.containsMouse ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "✔"; font.pixelSize: 13; color: "white"; font.weight: Font.ExtraBold }
                        Text {
                            id: okLbl
                            text: "Match Verified"
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                            color: "white"
                        }
                    }

                    MouseArea {
                        id: okHov
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if (root.currentClip) root.verified(root.currentClip)
                            if (root.currentIndex < (root.clipList.length - 1)) {
                                root.currentIndex++
                            } else {
                                root.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // Keyboard Shortcuts for Navigation & Zoom
    Shortcut {
        sequence: "Left"
        onActivated: if (root.currentIndex > 0) root.currentIndex--
    }
    Shortcut {
        sequence: "Right"
        onActivated: if (root.currentIndex < (root.clipList.length - 1)) root.currentIndex++
    }
    Shortcut {
        sequence: "Space"
        onActivated: {
            if (root.currentClip) root.verified(root.currentClip)
            if (root.currentIndex < (root.clipList.length - 1)) {
                root.currentIndex++
            } else {
                root.close()
            }
        }
    }
}
