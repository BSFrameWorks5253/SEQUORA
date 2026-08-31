// ============================================================
// qml/components/MatchedClipsView.qml
// Ultra-Modern Matched Clips Table View matching One Tap UI
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root
    required property var    theme
    property var    model:            []
    property var    dryRunResult:     null
    property string collisionPolicy:  "keepBoth"
    property string transferMode:     "copy"
    property bool   transferring:     false
    property int    transferPercent:  0
    property real   speedMbps:        0
    property int    etaSec:           0
    property string currentFile:      ""
    property bool   checkingDryRun:   false

    signal checkDryRun()
    signal startTransfer()
    signal undoTransfer()
    signal inspectClip(int index, var clip)

    implicitHeight: col.implicitHeight
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 10

        // Sticky-Style Control Header Card
        Rectangle {
            Layout.fillWidth: true
            height: 56
            radius: 12
            color: theme.surface
            border.color: theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                RowLayout {
                    spacing: 8
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: theme.successSoft
                        Text {
                            anchors.centerIn: parent
                            text: "✔"
                            font.pixelSize: 13
                            font.weight: Font.ExtraBold
                            color: theme.success
                        }
                    }
                    Text {
                        text: "Matched Clips (" + root.model.length + ")"
                        font.pixelSize: 14
                        font.weight: Font.ExtraBold
                        color: theme.textPrimary
                    }
                }

                Item { Layout.fillWidth: true }

                // Transfer Mode Segmented Toggle (Copy vs Move)
                Text {
                    text: "Mode:"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: theme.textMuted
                }

                Rectangle {
                    width: 140
                    height: 34
                    radius: 8
                    color: theme.surface2
                    border.color: theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2

                        // Copy Option
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: root.transferMode === "copy" ? theme.accent : "transparent"

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "📋"; font.pixelSize: 10 }
                                Text {
                                    text: "Copy"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: root.transferMode === "copy" ? "white" : theme.textMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.transferMode = "copy"
                                    root.transferModeChanged("copy")
                                }
                            }
                        }

                        // Move Option
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: root.transferMode === "move" ? theme.accent : "transparent"

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "📦"; font.pixelSize: 10 }
                                Text {
                                    text: "Move"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: root.transferMode === "move" ? "white" : theme.textMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.transferMode = "move"
                                    root.transferModeChanged("move")
                                }
                            }
                        }
                    }
                }

                Text {
                    text: "Collision:"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: theme.textMuted
                }

                ComboBox {
                    id: policyBox
                    Layout.preferredWidth: 110
                    height: 34
                    font.pixelSize: 11
                    model: ["keepBoth", "skip", "overwrite"]
                    onCurrentValueChanged: root.collisionPolicy = currentValue
                }

                // Verify & Inspect All button
                Rectangle {
                    width: inspectBtnLbl.implicitWidth + 24
                    height: 34
                    radius: 8
                    color: inspectHover.containsMouse ? theme.purpleSoft : theme.surfaceGlass
                    border.color: inspectHover.containsMouse ? theme.accent : theme.border_
                    border.width: 1
                    opacity: root.model.length > 0 ? 1.0 : 0.5

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "🔍"; font.pixelSize: 12 }
                        Text {
                            id: inspectBtnLbl
                            text: "Inspect & Zoom"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: inspectHover.containsMouse ? theme.accent : theme.textPrimary
                        }
                    }

                    MouseArea {
                        id: inspectHover
                        anchors.fill: parent
                        cursorShape: parent.opacity === 1.0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        onClicked: if (parent.opacity === 1.0 && root.model.length > 0) root.inspectClip(0, root.model[0])
                    }
                }

                // Pre-flight check button
                Rectangle {
                    width: checkBtnLbl.implicitWidth + 24
                    height: 34
                    radius: 8
                    color: checkHover.containsMouse ? theme.surface2 : theme.surfaceGlass
                    border.color: theme.border_
                    border.width: 1
                    opacity: (root.model.length > 0 && !root.checkingDryRun) ? 1.0 : 0.5

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "🔬"; font.pixelSize: 12 }
                        Text {
                            id: checkBtnLbl
                            text: root.checkingDryRun ? "Checking..." : "Pre-flight Check"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: theme.textPrimary
                        }
                    }

                    MouseArea {
                        id: checkHover
                        anchors.fill: parent
                        cursorShape: parent.opacity === 1.0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        onClicked: if (parent.opacity === 1.0) root.checkDryRun()
                    }
                }

                // Execute Transfer Primary Gradient Button
                Rectangle {
                    width: execBtnLbl.implicitWidth + 28
                    height: 36
                    radius: 8
                    opacity: (root.model.length > 0 && !root.transferring) ? 1.0 : 0.5

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: execHover.containsMouse ? (root.transferMode === "move" ? "#D97706" : "#8B65D4") : (root.transferMode === "move" ? "#B45309" : "#7C5CBF") }
                        GradientStop { position: 1.0; color: execHover.containsMouse ? (root.transferMode === "move" ? "#F59E0B" : "#A57EED") : (root.transferMode === "move" ? "#D97706" : "#946ED8") }
                    }

                    scale: execHover.pressed ? 0.97 : (execHover.containsMouse ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: root.transferMode === "move" ? "📦" : "🚀"; font.pixelSize: 13 }
                        Text {
                            id: execBtnLbl
                            text: root.transferring
                                  ? (root.transferMode === "move" ? "Moving " : "Transferring ") + root.transferPercent + "%..."
                                  : (root.transferMode === "move" ? "Execute Move (" : "Execute Copy (") + root.model.length + " clips)"
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                            color: "white"
                        }
                    }

                    MouseArea {
                        id: execHover
                        anchors.fill: parent
                        cursorShape: parent.opacity === 1.0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        onClicked: if (parent.opacity === 1.0) root.startTransfer()
                    }
                }
            }
        }

        // Dry Run Metrics Banner
        DryRunMetrics {
            Layout.fillWidth: true
            visible: root.dryRunResult !== null
            result: root.dryRunResult
            theme: root.theme
        }

        // Matched Clips List (Expands naturally in the main workspace flow)
        ListView {
            id: matchedLv
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            interactive: false
            model: root.model
            spacing: 6

            delegate: Rectangle {
                width: matchedLv.width
                height: 64
                radius: 10
                color: mHover.containsMouse
                       ? (theme.name === "dark" ? "#2B283E" : "#F0ECE5")
                       : (index % 2 === 0 ? theme.surface : theme.surface2)
                border.color: mHover.containsMouse ? theme.accent : theme.border_
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }

                MouseArea {
                    id: mHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    // Sequence Number Pill
                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 28
                        radius: 6
                        color: theme.purpleSoft
                        border.color: theme.accent
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData.sequence || "—"
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                            color: theme.accent
                        }
                    }

                    // Video -> Photo Folder Info
                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        RowLayout {
                            spacing: 6
                            Text { text: "🎬"; font.pixelSize: 12 }
                            Text {
                                text: modelData.videoName || ""
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: theme.textPrimary
                                elide: Text.ElideRight
                                Layout.maximumWidth: 260
                            }
                        }
                        RowLayout {
                            spacing: 6
                            Text { text: "➜ 📸"; font.pixelSize: 11; color: theme.accent }
                            Text {
                                text: modelData.photoFolderName || ""
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: theme.textMuted
                                elide: Text.ElideRight
                                Layout.maximumWidth: 260
                            }
                        }
                    }

                    // Video Thumbnail (_V.jpg) Preview Card
                    RowLayout {
                        spacing: 8
                        visible: modelData.videoThumbnailPath !== "" || modelData.photoThumbnailPath !== ""

                        // Video Thumb Pill (Click to Zoom & Compare)
                        Rectangle {
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 42
                            width: 130
                            height: 42
                            radius: 6
                            color: vThumbHov.containsMouse ? theme.purpleSoft : theme.surface
                            border.color: vThumbHov.containsMouse ? theme.accent : theme.border_
                            border.width: 1
                            clip: true
                            visible: modelData.videoThumbnailPath !== ""

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 6

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    width: 34
                                    height: 34
                                    radius: 4
                                    color: theme.surface2
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: modelData.videoThumbnailPath ? ("file:///" + modelData.videoThumbnailPath.replace(/\\/g, '/')) : ""
                                        sourceSize.width: 68
                                        sourceSize.height: 68
                                        asynchronous: true
                                        cache: true
                                        mipmap: true
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Layout.fillWidth: true
                                    Text {
                                        text: "🎬 _V.jpg 🔍"
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                        color: theme.accent
                                    }
                                    Text {
                                        text: modelData.videoThumbnailName || "_V.jpg"
                                        font.pixelSize: 9
                                        color: theme.textMuted
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            MouseArea {
                                id: vThumbHov
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.inspectClip(index, modelData)
                            }
                        }

                        // Photo Thumb Pill (Click to Zoom & Compare)
                        Rectangle {
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 42
                            width: 130
                            height: 42
                            radius: 6
                            color: pThumbHov.containsMouse ? theme.successSoft : theme.surface
                            border.color: pThumbHov.containsMouse ? theme.success : theme.border_
                            border.width: 1
                            clip: true
                            visible: modelData.photoThumbnailPath !== ""

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 6

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    width: 34
                                    height: 34
                                    radius: 4
                                    color: theme.surface2
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: modelData.photoThumbnailPath ? ("file:///" + modelData.photoThumbnailPath.replace(/\\/g, '/')) : ""
                                        sourceSize.width: 68
                                        sourceSize.height: 68
                                        asynchronous: true
                                        cache: true
                                        mipmap: true
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Layout.fillWidth: true
                                    Text {
                                        text: "📸 _P.jpg 🔍"
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                        color: theme.success
                                    }
                                    Text {
                                        text: modelData.photoThumbnailName || "_P.jpg"
                                        font.pixelSize: 9
                                        color: theme.textMuted
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            MouseArea {
                                id: pThumbHov
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.inspectClip(index, modelData)
                            }
                        }
                    }

                    // Date Folder Badge
                    Rectangle {
                        Layout.preferredHeight: 24
                        width: dTxt.implicitWidth + 14
                        radius: 6
                        color: theme.surface2
                        Text {
                            id: dTxt
                            anchors.centerIn: parent
                            text: "📅 " + (modelData.dateFolderName || "")
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: theme.textMuted
                        }
                    }

                    // Inspect & Zoom Button
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 8
                        color: inspectRowHov.containsMouse ? theme.purpleSoft : "transparent"
                        border.color: inspectRowHov.containsMouse ? theme.accent : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "🔍"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: inspectRowHov
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.inspectClip(index, modelData)
                        }
                    }

                    // Status Badge
                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 13
                        color: theme.successSoft
                        Text {
                            anchors.centerIn: parent
                            text: "✔"
                            font.pixelSize: 12
                            color: theme.success
                        }
                    }
                }
            }
        }
    }
}
