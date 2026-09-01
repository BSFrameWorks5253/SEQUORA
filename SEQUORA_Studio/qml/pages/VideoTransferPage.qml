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
        function onTransferProgress(curr, tot, fn, spd) {
            root.transferCurrentCount = curr || 0
            root.transferTotalCount = tot || 0
            root.transferCurrentFile = fn || ""
            root.transferSpeed = spd || ""
            root.transferProgress = tot > 0 ? (curr / tot) : 0.0
        }
        function onTransferCompleted(summary, trFiles) {
            root.isTransferring = false
            var c = trFiles ? trFiles.length : 0
            toast.show("✅ Transfer complete: " + c + " clips transferred successfully.", "success")
        }
        function onTransferError(reason) {
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
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 2
                Text {
                    text: "Sync Photo Video"
                    font.pixelSize: 22
                    font.weight: Font.Black
                    color: root.theme.textPrimary
                }
                Text {
                    text: "Pair multi-camera video clips with photo subfolders and synchronize thumbnails automatically."
                    font.pixelSize: 12
                    color: root.theme.textSecondary
                }
            }
            Item { Layout.fillWidth: true }
        }

        // ── 2. Directory Setup Card ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 16
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: dirSetupCol.implicitHeight + 32

            ColumnLayout {
                id: dirSetupCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Video Source
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "VIDEO SOURCE DIRECTORY"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            font.letterSpacing: 1.0
                            color: root.theme.textMuted
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                radius: 8
                                color: root.theme.surfaceElevated
                                border.color: root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8
                                    Text { text: "🎬"; font.pixelSize: 13; opacity: 0.7 }
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

                            StudioButton {
                                text: "Browse"
                                iconText: "📂"
                                variant: "glass"
                                btnSize: "md"
                                theme: root.theme
                                onClicked: {
                                    if (root.dialogs) {
                                        var c = root.dialogs.selectDirectory("Select Video Source Directory")
                                        if (c) root.videoDir = c
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
                            text: "PHOTO MASTER DIRECTORY"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            font.letterSpacing: 1.0
                            color: root.theme.textMuted
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                radius: 8
                                color: root.theme.surfaceElevated
                                border.color: root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8
                                    Text { text: "📸"; font.pixelSize: 13; opacity: 0.7 }
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

                            StudioButton {
                                text: "Browse"
                                iconText: "📂"
                                variant: "glass"
                                btnSize: "md"
                                theme: root.theme
                                onClicked: {
                                    if (root.dialogs) {
                                        var c = root.dialogs.selectDirectory("Select Photo Master Directory")
                                        if (c) root.photoDir = c
                                    }
                                }
                            }
                        }
                    }

                    // Scan & Compare Action
                    ColumnLayout {
                        spacing: 6
                        Layout.alignment: Qt.AlignBottom

                        Text { text: "ACTION"; font.pixelSize: 10; font.weight: Font.Black; font.letterSpacing: 1.0; color: root.theme.textMuted }

                        StudioButton {
                            text: root.isScanning ? "Comparing..." : "Scan & Compare"
                            iconText: "⚡"
                            variant: "success"
                            btnSize: "md"
                            enabled: root.videoDir !== "" && root.photoDir !== "" && !root.isScanning
                            loading: root.isScanning
                            theme: root.theme
                            onClicked: {
                                if (root.engine) {
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
            height: 48
            radius: 12
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    height: 30
                    width: totClipsRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.surface2
                    RowLayout {
                        id: totClipsRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.matched.length + root.unmatched.length); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textPrimary }
                        Text { text: "Clips Total"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textSecondary }
                    }
                }

                Rectangle {
                    height: 30
                    width: matClipsRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                    border.color: root.theme.isDark ? "#10B981" : "#A7F3D0"
                    border.width: 1
                    RowLayout {
                        id: matClipsRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.matched.length); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.success }
                        Text { text: "Matched"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.success }
                    }
                }

                Rectangle {
                    height: 30
                    width: revClipsRow.implicitWidth + 18
                    radius: 7
                    color: root.unmatched.length > 0 ? (root.theme.isDark ? "#4C0519" : "#FFF1F2") : root.theme.surface2
                    border.color: root.unmatched.length > 0 ? (root.theme.isDark ? "#F43F5E" : "#FECACA") : "transparent"
                    border.width: 1
                    RowLayout {
                        id: revClipsRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.unmatched.length); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.unmatched.length > 0 ? root.theme.danger : root.theme.textMuted }
                        Text { text: "Require Review"; font.pixelSize: 11; font.weight: Font.Bold; color: root.unmatched.length > 0 ? root.theme.danger : root.theme.textMuted }
                    }
                }

                Text {
                    text: "✓ Non-video event folders (MQ, MF, H) automatically bypassed"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: root.theme.success
                    leftPadding: 8
                }

                Item { Layout.fillWidth: true }

                // ── Verify Sequence Pairs (Modal Inspector) ───────────────────
                StudioButton {
                    text: "Verify Pairs"
                    iconText: "🔍"
                    variant: "primary"
                    btnSize: "sm"
                    enabled: (root.matched.length + root.unmatched.length) > 0
                    theme: root.theme
                    onClicked: verifyModal.openForPair(0, "ALL")
                }
            }
        }

        // ── 4. Main Tabular Workspace ─────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
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
                    height: 36
                    color: root.theme.surface2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text { text: "VIDEO CLIP"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 240 }
                        Text { text: "PHOTO FOLDER TARGET"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                        Text { text: "STATUS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 90 }
                        Text { text: "ACTIONS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 160; horizontalAlignment: Text.AlignRight }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: root.theme.borderSubtle
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
                        height: 44
                        color: rowHov.containsMouse ? root.theme.surface2 : "transparent"

                        MouseArea {
                            id: rowHov
                            anchors.fill: parent
                            hoverEnabled: true
                            z: 0
                            onDoubleClicked: verifyModal.openForPair(index, "ALL")
                        }

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
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12
                            z: 1

                            // Video Clip
                            RowLayout {
                                Layout.preferredWidth: 240
                                spacing: 8

                                Rectangle {
                                    width: 32; height: 24; radius: 5
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

                            // Action Buttons: Link Folder / Verify
                            RowLayout {
                                Layout.preferredWidth: 160
                                spacing: 6
                                Layout.alignment: Qt.AlignRight

                                StudioButton {
                                    text: modelData.isMatched ? "Edit Link" : "Link Folder"
                                    iconText: "🔗"
                                    variant: modelData.isMatched ? "glass" : "cyan"
                                    btnSize: "sm"
                                    theme: root.theme
                                    onClicked: {
                                        folderLinkDialog.openForVideo(modelData)
                                    }
                                }

                                StudioButton {
                                    text: "Inspect"
                                    iconText: "🔍"
                                    variant: "glass"
                                    btnSize: "sm"
                                    theme: root.theme
                                    onClicked: {
                                        verifyModal.openForPair(index, "ALL")
                                    }
                                }
                            }
                        }
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
            height: 56
            radius: 12
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
                    Text { text: "TRANSFER MODE"; font.pixelSize: 10; font.weight: Font.Black; font.letterSpacing: 1.0; color: root.theme.textMuted }

                    RowLayout {
                        spacing: 4
                        RadioButton {
                            id: rbCopy
                            text: "Copy"
                            checked: root.transferMode === "COPY"
                            onClicked: {
                                root.transferMode = "COPY"
                                if (root.engine) root.engine.transferMode = "copy"
                            }
                        }
                        RadioButton {
                            id: rbMove
                            text: "Move"
                            checked: root.transferMode === "MOVE"
                            onClicked: {
                                root.transferMode = "MOVE"
                                if (root.engine) root.engine.transferMode = "move"
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                StudioButton {
                    text: root.isTransferring ? "Transferring..." : "Start Video Transfer"
                    iconText: "🚀"
                    variant: "success"
                    btnSize: "md"
                    enabled: root.matched.length > 0 && !root.isTransferring
                    loading: root.isTransferring
                    theme: root.theme
                    onClicked: {
                        if (root.engine) {
                            root.isTransferring = true
                            root.engine.executeTransfer(root.matched)
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
    }

    // ── Folder Link Dialog ───────────────────────────────────────────────────
    FolderLinkDialog {
        id: folderLinkDialog
        theme: root.theme
        photoFoldersByDate: root.photoFoldersByDate
        onFolderSelected: (vPath, pPath, pName) => {
            if (root.engine) {
                root.engine.linkVideoToPhotoFolder(vPath, pPath)
                toast.show("✓ Linked video to " + pName, "success")
            }
        }
    }

    // ── Sequence Verification & Dual Thumbnail Inspector Modal ───────────────
    SequenceVerificationModal {
        id: verifyModal
        theme: root.theme
        pairs: [].concat(root.matched).concat(root.unmatched)
        photoFoldersByDate: root.photoFoldersByDate
        onRequestRelink: (item) => folderLinkDialog.openForVideo(item)
    }

    // ── Toast Notification ────────────────────────────────────────────────────
    ToastNotification { id: toast; theme: root.theme }
}
