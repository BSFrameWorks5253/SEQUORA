// ============================================================
// qml/pages/VideoTransferPage.qml
// Screen 3: Video Sequence Matcher (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property var engine: typeof videoEngine !== "undefined" ? videoEngine : null
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
    required property var theme

    // Directory State
    property string videoDir: ""
    property string photoDir: ""

    // Matched / Unmatched Models
    property var matched: []
    property var unmatched: []
    property var photoFoldersByDate: ({})
    property string transferMode: "COPY" // "COPY" | "MOVE"

    property bool isScanning: false
    property bool isTransferring: false
    property real transferProgress: 0.0
    property string transferCurrentFile: ""
    property string transferSpeed: ""
    property int transferCurrentCount: 0
    property int transferTotalCount: 0

    // ── Backend Connections ───────────────────────────────────────────────────
    Connections {
        target: root.engine
        ignoreUnknownSignals: true

        function onMatchedItemsChanged(items) { root.matched = items || [] }
        function onUnmatchedItemsChanged(items) { root.unmatched = items || [] }
        function onPhotoFoldersByDateChanged(pfd) { root.photoFoldersByDate = pfd || {} }
        function onTransferModeChanged(mode) { root.transferMode = mode }
        function onScanResultReady(success, errorMsg) {
            root.isScanning = false
            if (success) {
                toast.show("Scan complete: " + root.matched.length + " paired clips found.", "success")
            } else if (errorMsg) {
                toast.show(errorMsg, "danger")
            }
        }
        function onTransferProgressChanged(current, total, filename, speed) {
            root.transferCurrentCount = current
            root.transferTotalCount = total
            root.transferCurrentFile = filename
            root.transferSpeed = speed
            root.transferProgress = total > 0 ? (current / total) : 0.0
        }
        function onTransferComplete(summary) {
            root.isTransferring = false
            toast.show("✅ Transfer complete: " + (summary ? summary.transferredClips : 0) + " clips transferred successfully.", "success")
        }
        function onTransferFailed(reason) {
            root.isTransferring = false
            toast.show("Transfer error: " + reason, "danger")
        }
    }

    // ── Main Layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ── 1. Page Header ────────────────────────────────────────────────────
        ColumnLayout {
            spacing: 2
            Text {
                text: "Video Sequence Matcher"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: root.theme.textPrimary
            }
            Text {
                text: "Pair video clips with corresponding photo folders automatically."
                font.pixelSize: 13
                color: root.theme.textSecondary
            }
        }

        // ── 2. Directory Setup Card ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: dirSetupCol.implicitHeight + 28

            ColumnLayout {
                id: dirSetupCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Video Source
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "VIDEO SOURCE"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 1.0
                            color: root.theme.textMuted
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 36
                                radius: 6
                                color: root.theme.surfaceElevated
                                border.color: root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8
                                    Text { text: "🎬"; font.pixelSize: 12; opacity: 0.7 }
                                    Text {
                                        text: root.videoDir || "Select video source folder..."
                                        font.pixelSize: 12
                                        font.family: "Consolas, monospace"
                                        color: root.videoDir ? root.theme.textPrimary : root.theme.textMuted
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            Rectangle {
                                width: 80
                                height: 36
                                radius: 6
                                color: vChgHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
                                border.color: root.theme.border_
                                border.width: 1

                                Text { anchors.centerIn: parent; text: "Change"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                MouseArea {
                                    id: vChgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs) {
                                            var c = root.dialogs.chooseDirectory("Select Video Source Directory", root.videoDir)
                                            if (c) root.videoDir = c
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Photo Master
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "PHOTO MASTER"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 1.0
                            color: root.theme.textMuted
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 36
                                radius: 6
                                color: root.theme.surfaceElevated
                                border.color: root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8
                                    Text { text: "📸"; font.pixelSize: 12; opacity: 0.7 }
                                    Text {
                                        text: root.photoDir || "Select master photo folder..."
                                        font.pixelSize: 12
                                        font.family: "Consolas, monospace"
                                        color: root.photoDir ? root.theme.textPrimary : root.theme.textMuted
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            Rectangle {
                                width: 80
                                height: 36
                                radius: 6
                                color: pChgHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
                                border.color: pChgHov.containsMouse ? root.theme.borderHover : root.theme.border_
                                border.width: 1
                                scale: pChgHov.pressed ? 0.96 : (pChgHov.containsMouse ? 1.02 : 1.0)
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Text { anchors.centerIn: parent; text: "Change"; font.pixelSize: 12; font.weight: Font.Bold; color: root.theme.textPrimary }
                                MouseArea {
                                    id: pChgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs) {
                                            var c = root.dialogs.chooseDirectory("Select Photo Master Directory", root.photoDir)
                                            if (c) root.photoDir = c
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Scan & Compare Button
                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        width: 145
                        height: 36
                        radius: 6
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: scnCmpHov.containsMouse ? "#10B981" : "#059669" }
                            GradientStop { position: 1.0; color: scnCmpHov.containsMouse ? "#059669" : "#047857" }
                        }
                        enabled: root.videoDir !== "" && root.photoDir !== "" && !root.isScanning
                        scale: scnCmpHov.pressed ? 0.96 : (scnCmpHov.containsMouse ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "⚡"; font.pixelSize: 12 }
                            Text {
                                text: root.isScanning ? "Comparing..." : "Scan & Compare"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: scnCmpHov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (parent.enabled && root.engine) {
                                    root.isScanning = true
                                    root.engine.scanFolder({ videoFolderPath: root.videoDir, photoFolderPath: root.photoDir })
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── 3. Match Summary Strip & Rule ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    height: 28
                    width: totClipsRow.implicitWidth + 16
                    radius: 5
                    color: root.theme.surface2
                    RowLayout {
                        id: totClipsRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.matched.length + root.unmatched.length); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textPrimary }
                        Text { text: "Clips Total"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textSecondary }
                    }
                }

                Rectangle {
                    height: 28
                    width: matClipsRow.implicitWidth + 16
                    radius: 5
                    color: "#ECFDF5"
                    border.color: "#A7F3D0"
                    border.width: 1
                    RowLayout {
                        id: matClipsRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.matched.length); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: "#059669" }
                        Text { text: "Matched"; font.pixelSize: 11; font.weight: Font.Bold; color: "#059669" }
                    }
                }

                Rectangle {
                    height: 28
                    width: revClipsRow.implicitWidth + 16
                    radius: 5
                    color: root.unmatched.length > 0 ? "#FEF2F2" : root.theme.surface2
                    border.color: root.unmatched.length > 0 ? "#FECACA" : "transparent"
                    border.width: 1
                    RowLayout {
                        id: revClipsRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.unmatched.length); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.unmatched.length > 0 ? "#DC2626" : root.theme.textMuted }
                        Text { text: "Require Review"; font.pixelSize: 11; font.weight: Font.Bold; color: root.unmatched.length > 0 ? "#DC2626" : root.theme.textMuted }
                    }
                }

                Text {
                    text: "✓ Non-video event folders (MQ, MF, H) automatically ignored"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#059669"
                    leftPadding: 8
                }

                Item { Layout.fillWidth: true }
            }
        }

        // ── 4. Main Tabular Workspace (Review Required + Matched Clips) ───────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Table Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    color: root.theme.surface2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Text { text: "VIDEO CLIP"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 260 }
                        Text { text: "PHOTO FOLDER TARGET"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                        Text { text: "STATUS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 100 }
                        Text { text: "ACTION"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: root.theme.border_
                    }
                }

                // Table Scroll Area
                ListView {
                    id: pairList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: [].concat(root.unmatched).concat(root.matched)
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 48
                        color: rowHov.containsMouse ? root.theme.surface2 : "transparent"

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
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            // Video Clip with small thumbnail icon
                            RowLayout {
                                Layout.preferredWidth: 260
                                spacing: 8

                                Rectangle {
                                    width: 32; height: 24; radius: 3
                                    color: root.theme.surfaceElevated
                                    border.color: root.theme.border_
                                    border.width: 1

                                    Image {
                                        anchors.fill: parent
                                        source: modelData.videoThumbnailPath ? ("file:///" + modelData.videoThumbnailPath) : ""
                                        fillMode: Image.PreserveAspectCrop
                                        visible: modelData.videoThumbnailPath !== ""
                                    }
                                    Text {
                                        visible: !modelData.videoThumbnailPath
                                        anchors.centerIn: parent
                                        text: "🎬"
                                        font.pixelSize: 10
                                    }
                                }

                                Text {
                                    text: modelData.videoName || (modelData.photoFolderName ? ("Photo Subfolder: " + modelData.photoFolderName) : "Clip")
                                    font.pixelSize: 12
                                    font.family: "Consolas, monospace"
                                    color: root.theme.textPrimary
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }

                            // Photo Target Folder
                            Text {
                                text: modelData.photoFolderName || (modelData.reason ? modelData.reason : "— Unpaired —")
                                font.pixelSize: 12
                                color: modelData.isMatched ? root.theme.textSecondary : root.theme.danger
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            // Semantic Status Pill Badge
                            SemanticBadge {
                                Layout.preferredWidth: 90
                                theme: root.theme
                                type: modelData.isMatched ? "matched" : "mismatch"
                                text: modelData.isMatched ? "Matched" : "Review"
                                showDot: true
                            }

                            // Actions
                            RowLayout {
                                Layout.preferredWidth: 120
                                spacing: 6

                                Rectangle {
                                    visible: !modelData.isMatched
                                    height: 24
                                    width: 60
                                    radius: 4
                                    color: ignHov.containsMouse ? root.theme.surface2 : "transparent"
                                    border.color: root.theme.border_
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Ignore"
                                        font.pixelSize: 11
                                        color: root.theme.textMuted
                                    }

                                    MouseArea {
                                        id: ignHov; anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.engine) root.engine.ignoreSingleMismatch(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea { id: rowHov; anchors.fill: parent; hoverEnabled: true }
                    }

                    // Skeleton Shimmer Loader during scanning
                    SkeletonLoader {
                        anchors.fill: parent
                        anchors.margins: 14
                        theme: root.theme
                        visible: root.isScanning
                        rowCount: 5
                        cardHeight: 44
                        rowSpacing: 6
                    }

                    // Empty State
                    Item {
                        anchors.centerIn: parent
                        visible: !root.isScanning && root.matched.length === 0 && root.unmatched.length === 0
                        width: parent.width

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "No video pairs scanned"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Select Video Source and Photo Master directories above and click Scan & Compare."
                                font.pixelSize: 13
                                color: root.theme.textMuted
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }

        // ── 5. Transfer Execution Control Bar ─────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 52
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

                // Mode Selector
                RowLayout {
                    spacing: 12
                    Text { text: "TRANSFER MODE"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }

                    RowLayout {
                        spacing: 4
                        RadioButton {
                            id: rbCopy
                            text: "Copy"
                            checked: root.transferMode === "COPY"
                            onClicked: {
                                root.transferMode = "COPY"
                                if (root.engine) root.engine.setTransferMode("COPY")
                            }
                        }
                        RadioButton {
                            id: rbMove
                            text: "Move"
                            checked: root.transferMode === "MOVE"
                            onClicked: {
                                root.transferMode = "MOVE"
                                if (root.engine) root.engine.setTransferMode("MOVE")
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Start Transfer Action
                Rectangle {
                    width: 175
                    height: 38
                    radius: 6
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: trsHov.containsMouse ? "#10B981" : "#059669" }
                        GradientStop { position: 1.0; color: trsHov.containsMouse ? "#059669" : "#047857" }
                    }
                    enabled: root.matched.length > 0 && root.unmatched.length === 0 && !root.isTransferring
                    scale: trsHov.pressed ? 0.96 : (trsHov.containsMouse ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "🚀"; font.pixelSize: 12 }
                        Text {
                            text: root.isTransferring ? "Transferring..." : "Start Transfer →"
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: trsHov; anchors.fill: parent; hoverEnabled: true
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (parent.enabled && root.engine) {
                                root.isTransferring = true
                                root.engine.executeTransfer()
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Operation Progress Overlay ────────────────────────────────────────────
    ProgressOverlay {
        theme: root.theme
        visible_: root.isTransferring
        title: "Transferring video clips..."
        message: "Speed: " + (root.transferSpeed || "Calculating...")
        currentFile: root.transferCurrentFile
        currentCount: root.transferCurrentCount
        totalCount: root.transferTotalCount
        progress: root.transferProgress
        onCancelClicked: if (root.engine) root.engine.cancelTransfer()
    }

    // ── Toast Notification ────────────────────────────────────────────────────
    ToastNotification { id: toast; theme: root.theme }
}
