// ============================================================
// qml/pages/PVSeparatorPage.qml
// Screen: High-Speed Photo vs Video Separator (100% Exact One Tap V20.6.5 Logic)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    required property var theme
    property var engine: typeof pvSeparatorEngine !== "undefined" ? pvSeparatorEngine : (typeof thumbEngine !== "undefined" ? thumbEngine : null)
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null

    contentWidth: availableWidth
    clip: true

    // State Variables (matching One Tap V20.6.5)
    property string sourceDir: ""
    property string destDir: ""
    property string actionMode: "copy" // "copy" | "move"

    property bool isScanning: engine ? engine.scanning : false
    property bool isProcessing: engine ? engine.isProcessing : false

    property var scanData: null
    property string scannedSource: ""
    property string statusLabel: "Ready"
    property string statusVariant: "info" // "info" | "success" | "warning" | "danger"

    property real progressPct: 0
    property string progressLabel: "Ready"
    property real speedMbps: 0.0
    property int etaSec: 0
    property var logLines: []

    function addLog(msg, type) {
        var lines = root.logLines.slice()
        lines.push({
            text: msg,
            type: type || "info",
            time: Qt.formatTime(new Date(), "hh:mm:ss")
        })
        if (lines.length > 300) lines.shift()
        root.logLines = lines
    }

    function clearLogs() {
        root.logLines = []
    }

    function formatBytes(bytes) {
        if (!bytes || bytes === 0) return "0 B"
        var k = 1024
        var sizes = ["B", "KB", "MB", "GB", "TB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i]
    }

    function formatEta(seconds) {
        if (!seconds || seconds <= 0) return "00:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return (mins < 10 ? "0" + mins : mins) + ":" + (secs < 10 ? "0" + secs : secs)
    }

    // Backend Signal Connections
    Connections {
        target: root.engine
        function onScanCompleted(result) {
            root.scanData = result
            root.scannedSource = root.sourceDir.trim()
            var photoMB = (result.photo_bytes / (1024 * 1024)).toFixed(1)
            var foldCount = result.event_folders ? result.event_folders.length : 0
            root.addLog("Analysis complete: Found " + result.total_photos + " photos (" + photoMB + " MB) across " + foldCount + " folder(s). " + result.total_videos + " video files untouched.", "success")
            root.statusLabel = "Analysis Complete"
            root.statusVariant = "info"
            toast.show("Scan complete: " + result.total_photos + " photos identified (" + photoMB + " MB)", "info")

            // If processing was triggered, immediately start processing
            if (root.pendingAutoProcess) {
                root.pendingAutoProcess = false
                root.executeProcessing()
            }
        }
        function onProgress(data) {
            if (data.total > 0) {
                root.progressPct = Math.min(100, Math.round((data.current / data.total) * 100))
            }
            if (data.label) root.progressLabel = data.label
            if (data.speed_mbps !== undefined) root.speedMbps = data.speed_mbps
            if (data.eta_sec !== undefined) root.etaSec = data.eta_sec
            if (data.log_entry) {
                root.addLog(data.log_entry, data.log_type || "info")
            }
        }
        function onProcessingCompleted(result) {
            root.progressPct = 100
            root.progressLabel = "Complete!"
            root.statusLabel = "Complete!"
            root.statusVariant = "success"
            root.addLog("Completed! " + result.success_count + " photo files processed in " + result.elapsed_sec + "s (Avg " + result.avg_speed_mbps + " MB/s, " + result.error_count + " errors)", "success")
            confetti.fire()
            toast.show("✓ Separation complete: " + result.success_count + " photos processed!", "success")
        }
        function onError(errMsg) {
            root.addLog("Error: " + errMsg, "error")
            root.statusLabel = "Error"
            root.statusVariant = "danger"
            toast.show("⚠ " + errMsg, "error")
        }
    }

    property bool pendingAutoProcess: false

    function handleSingleAction() {
        var sDir = root.sourceDir.trim()
        var dDir = root.destDir.trim()

        if (!sDir) {
            toast.show("Please select a source directory first.", "warning")
            return
        }
        if (!dDir) {
            toast.show("Please select a destination directory first.", "warning")
            return
        }

        // Auto-scan if not scanned yet or if path changed
        if (!root.scanData || root.scannedSource !== sDir) {
            root.statusLabel = "Analyzing Media..."
            root.statusVariant = "info"
            root.addLog("Analyzing source directory: " + sDir, "info")
            root.pendingAutoProcess = true
            if (root.engine) root.engine.scanFolder(sDir)
            return
        }

        if (root.scanData.total_photos === 0) {
            toast.show("No photo files were found in the selected source directory.", "warning")
            return
        }

        executeProcessing()
    }

    function executeProcessing() {
        var sDir = root.sourceDir.trim()
        var dDir = root.destDir.trim()
        root.progressLabel = "Starting parallel extraction..."
        root.progressPct = 0
        root.speedMbps = 0
        root.etaSec = 0
        root.statusLabel = "Extracting Photos..."
        root.statusVariant = "warning"
        root.addLog("Starting high-speed " + (root.actionMode === "copy" ? "Copy" : "Move") + " extraction with 16 parallel worker threads...", "info")

        if (root.engine) {
            root.engine.startProcessing(sDir, dDir, root.actionMode)
        }
    }

    ColumnLayout {
        width: Math.min(1180, parent.width - 48)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18

        Item { height: 10 }

        // ── Page Hero Header ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 72
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 14

                Rectangle {
                    width: 44; height: 44; radius: 10
                    color: root.theme.isDark ? "#2E2412" : "#FEF3C7"
                    border.color: root.theme.isDark ? "#D97706" : "#FDE68A"
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "📦"; font.pixelSize: 22 }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Text {
                        text: "PV Separator (Photo & Video Separator)"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: root.theme.textPrimary
                    }
                    Text {
                        text: "Ultra-fast Photo (P) vs Video (V) file classification, separation, and organization."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                    }
                }

                // Header Status Chips
                RowLayout {
                    spacing: 8
                    Rectangle {
                        height: 26; width: 100; radius: 13
                        color: root.theme.surface2
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "⚡ " + root.speedMbps.toFixed(1) + " MB/s"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.info }
                    }
                    Rectangle {
                        height: 26; width: 95; radius: 13
                        color: root.theme.surface2
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "⚡ 16 Threads"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.warning }
                    }
                    Rectangle {
                        height: 26; width: 85; radius: 13
                        color: root.theme.surface2
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "v3.0 Ultra"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textMuted }
                    }
                }
            }
        }

        // ── 2-Column Split Workspace ────────────────────────────────
        GridLayout {
            columns: parent.width > 900 ? 2 : 1
            Layout.fillWidth: true
            columnSpacing: 18
            rowSpacing: 18

            // ── Left Column: Media Directories & Controls ───────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width > 900 ? 460 : parent.width
                radius: 8
                color: root.theme.surface
                border.color: root.theme.border_
                border.width: 1
                implicitHeight: leftColContent.implicitHeight + 32

                ColumnLayout {
                    id: leftColContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 14

                    Text {
                        text: "MEDIA DIRECTORIES & CONTROLS"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.1
                        color: root.theme.accent
                    }

                    // Source Directory
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Source Directory (Photos & Videos)"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: root.theme.textSecondary
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                height: 36
                                radius: 6
                                color: root.theme.surface2
                                border.color: root.theme.border_
                                border.width: 1

                                TextInput {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.pixelSize: 12
                                    color: root.theme.textPrimary
                                    text: root.sourceDir
                                    onTextChanged: root.sourceDir = text
                                }
                            }

                            Rectangle {
                                height: 36; width: 85
                                radius: 6
                                color: btnBrowseSrc.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                                border.color: root.theme.border_
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "Browse"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                MouseArea {
                                    id: btnBrowseSrc; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs && root.dialogs.selectDirectory) {
                                            var p = root.dialogs.selectDirectory("Select Source Directory (Photos & Videos)")
                                            if (p) {
                                                root.sourceDir = p
                                                root.addLog("Source directory set: " + p, "info")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Destination Directory
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Destination Directory (Photo Data Output)"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: root.theme.textSecondary
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                height: 36
                                radius: 6
                                color: root.theme.surface2
                                border.color: root.theme.border_
                                border.width: 1

                                TextInput {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.pixelSize: 12
                                    color: root.theme.textPrimary
                                    text: root.destDir
                                    onTextChanged: root.destDir = text
                                }
                            }

                            Rectangle {
                                height: 36; width: 85
                                radius: 6
                                color: btnBrowseDst.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                                border.color: root.theme.border_
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "Browse"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                MouseArea {
                                    id: btnBrowseDst; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs && root.dialogs.selectDirectory) {
                                            var p = root.dialogs.selectDirectory("Select Destination Directory")
                                            if (p) {
                                                root.destDir = p
                                                root.addLog("Destination directory set: " + p, "info")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Extraction Mode Pills
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "EXTRACTION MODE"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.letterSpacing: 0.8
                            color: root.theme.textMuted
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                radius: 6
                                color: root.actionMode === "copy" ? root.theme.accent : root.theme.surface2
                                border.color: root.actionMode === "copy" ? root.theme.accent : root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "📋"; font.pixelSize: 13 }
                                    Text {
                                        text: "Copy (Safe)"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: root.actionMode === "copy" ? "#FFFFFF" : root.theme.textSecondary
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.actionMode = "copy"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                radius: 6
                                color: root.actionMode === "move" ? root.theme.accent : root.theme.surface2
                                border.color: root.actionMode === "move" ? root.theme.accent : root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "📦"; font.pixelSize: 13 }
                                    Text {
                                        text: "Move"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: root.actionMode === "move" ? "#FFFFFF" : root.theme.textSecondary
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.actionMode = "move"
                                }
                            }
                        }
                    }

                    // Single Unified Action Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 46
                        radius: 8
                        color: (root.isScanning || root.isProcessing) ? root.theme.surface2 : (btnActionHov.containsMouse ? root.theme.accentHover : root.theme.accent)
                        opacity: (root.sourceDir.trim() !== "" && root.destDir.trim() !== "") ? 1.0 : 0.5
                        enabled: (root.sourceDir.trim() !== "" && root.destDir.trim() !== "") && !root.isScanning && !root.isProcessing

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: root.isScanning ? "⏳" : (root.isProcessing ? "⚡" : "🚀")
                                font.pixelSize: 15
                            }
                            Text {
                                text: root.isScanning ? "Analyzing Media..." : (root.isProcessing ? "Extracting Photos..." : "Start Photo Extraction")
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: btnActionHov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.handleSingleAction()
                        }
                    }

                    // Status Chip
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        height: 24; width: 140; radius: 12
                        color: root.statusVariant === "success" ? root.theme.successSoft : (root.statusVariant === "warning" ? root.theme.warningSoft : (root.statusVariant === "danger" ? root.theme.dangerSoft : root.theme.surface2))
                        border.color: root.statusVariant === "success" ? root.theme.success : (root.statusVariant === "warning" ? root.theme.warning : root.theme.border_)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.statusLabel
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: root.statusVariant === "success" ? root.theme.success : (root.statusVariant === "warning" ? root.theme.warning : (root.statusVariant === "danger" ? root.theme.danger : root.theme.textSecondary))
                        }
                    }
                }
            }

            // ── Right Column: Scan Analysis & Media Payload HUD ──────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: root.theme.surface
                border.color: root.theme.border_
                border.width: 1
                implicitHeight: rightColContent.implicitHeight + 32

                ColumnLayout {
                    id: rightColContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 14

                    Text {
                        text: "SCAN ANALYSIS & MEDIA PAYLOAD"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.1
                        color: root.theme.accent
                    }

                    // Empty State
                    Item {
                        visible: root.scanData === null
                        Layout.fillWidth: true
                        height: 240

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "📂"
                                font.pixelSize: 42
                                Layout.alignment: Qt.AlignHCenter
                                opacity: 0.7
                            }
                            Text {
                                text: "Ready for Analysis & Extraction"
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                color: root.theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Select your source and destination directories on the left, then click Start Photo Extraction to analyze and extract photo data in one click."
                                font.pixelSize: 12
                                color: root.theme.textMuted
                                Layout.preferredWidth: 380
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Scanned State
                    ColumnLayout {
                        visible: root.scanData !== null
                        Layout.fillWidth: true
                        spacing: 12

                        // 4 Stat Cards Grid
                        GridLayout {
                            columns: 4
                            Layout.fillWidth: true
                            columnSpacing: 10
                            rowSpacing: 10

                            Rectangle {
                                Layout.fillWidth: true; height: 64; radius: 6; color: root.theme.surface2
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 2
                                    Text { text: "Total Files"; font.pixelSize: 10; color: root.theme.textMuted }
                                    Text { text: String(root.scanData ? root.scanData.total_files : 0); font.pixelSize: 15; font.weight: Font.Bold; color: root.theme.textPrimary }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 64; radius: 6; color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                                border.color: root.theme.isDark ? "#059669" : "#A7F3D0"; border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 2
                                    Text { text: "Photos Extracted"; font.pixelSize: 10; color: root.theme.isDark ? "#A7F3D0" : "#065F46" }
                                    Text { text: String(root.scanData ? root.scanData.total_photos : 0); font.pixelSize: 15; font.weight: Font.Bold; color: "#10B981" }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 64; radius: 6; color: root.theme.isDark ? "#2A1E4A" : "#F3EEFC"
                                border.color: root.theme.isDark ? "#6D28D9" : "#DDD6FE"; border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 2
                                    Text { text: "Photo Payload"; font.pixelSize: 10; color: root.theme.isDark ? "#DDD6FE" : "#4C1D95" }
                                    Text { text: root.scanData ? root.formatBytes(root.scanData.photo_bytes) : "0 B"; font.pixelSize: 14; font.weight: Font.Bold; color: "#8B5CF6" }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 64; radius: 6; color: root.theme.isDark ? "#3A2A08" : "#FEF3C7"
                                border.color: root.theme.isDark ? "#D97706" : "#FDE68A"; border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 2
                                    Text { text: "Videos Untouched"; font.pixelSize: 10; color: root.theme.isDark ? "#FDE68A" : "#92400E" }
                                    Text { text: String(root.scanData ? root.scanData.total_videos : 0); font.pixelSize: 15; font.weight: Font.Bold; color: "#F59E0B" }
                                }
                            }
                        }

                        // 3 Extension Category Cards
                        GridLayout {
                            columns: 3
                            Layout.fillWidth: true
                            columnSpacing: 10
                            rowSpacing: 10

                            // Photos & Sidecars Card
                            Rectangle {
                                Layout.fillWidth: true; height: 110; radius: 6; color: root.theme.surface2; border.color: root.theme.borderSubtle; border.width: 1
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                                    Text { text: "Photos & Sidecars"; font.pixelSize: 11; font.weight: Font.Bold; color: "#10B981" }
                                    Flow {
                                        Layout.fillWidth: true; spacing: 4
                                        Repeater {
                                            model: root.scanData && root.scanData.photo_exts ? Object.keys(root.scanData.photo_exts) : []
                                            delegate: Rectangle {
                                                height: 22; width: extTxt.implicitWidth + 12; radius: 4
                                                color: root.theme.surface; border.color: root.theme.border_; border.width: 1
                                                Text { id: extTxt; anchors.centerIn: parent; text: modelData + " (" + root.scanData.photo_exts[modelData] + ")"; font.pixelSize: 10; color: root.theme.textPrimary }
                                            }
                                        }
                                    }
                                }
                            }

                            // Videos Card
                            Rectangle {
                                Layout.fillWidth: true; height: 110; radius: 6; color: root.theme.surface2; border.color: root.theme.borderSubtle; border.width: 1
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                                    Text { text: "Videos (In Source)"; font.pixelSize: 11; font.weight: Font.Bold; color: "#F59E0B" }
                                    Flow {
                                        Layout.fillWidth: true; spacing: 4
                                        Repeater {
                                            model: root.scanData && root.scanData.video_exts ? Object.keys(root.scanData.video_exts) : []
                                            delegate: Rectangle {
                                                height: 22; width: extTxt2.implicitWidth + 12; radius: 4
                                                color: root.theme.surface; border.color: root.theme.border_; border.width: 1
                                                Text { id: extTxt2; anchors.centerIn: parent; text: modelData + " (" + root.scanData.video_exts[modelData] + ")"; font.pixelSize: 10; color: root.theme.textPrimary }
                                            }
                                        }
                                    }
                                }
                            }

                            // Other Media Card
                            Rectangle {
                                Layout.fillWidth: true; height: 110; radius: 6; color: root.theme.surface2; border.color: root.theme.borderSubtle; border.width: 1
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                                    Text { text: "Other Media"; font.pixelSize: 11; font.weight: Font.Bold; color: "#8B5CF6" }
                                    Flow {
                                        Layout.fillWidth: true; spacing: 4
                                        Repeater {
                                            model: root.scanData && root.scanData.audio_exts ? Object.keys(root.scanData.audio_exts) : []
                                            delegate: Rectangle {
                                                height: 22; width: extTxt3.implicitWidth + 12; radius: 4
                                                color: root.theme.surface; border.color: root.theme.border_; border.width: 1
                                                Text { id: extTxt3; anchors.centerIn: parent; text: modelData + " (" + root.scanData.audio_exts[modelData] + ")"; font.pixelSize: 10; color: root.theme.textPrimary }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Bottom Panel: Extraction Progress & Terminal LogBox ─────
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: progCol.implicitHeight + 32

            ColumnLayout {
                id: progCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "EXTRACTION PROGRESS & TERMINAL"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.1
                        color: root.theme.accent
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        height: 24; width: 65; radius: 4
                        color: btnClearLog.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                        border.color: root.theme.border_
                        border.width: 1
                        Text { anchors.centerIn: parent; text: "Clear Logs"; font.pixelSize: 10; color: root.theme.textMuted }
                        MouseArea {
                            id: btnClearLog; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.clearLogs()
                        }
                    }
                }

                // Progress Bar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.progressLabel
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: root.theme.textPrimary
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "⚡ " + root.speedMbps.toFixed(1) + " MB/s  |  ⏱ ETA: " + root.formatEta(root.etaSec)
                            font.pixelSize: 11
                            font.family: "Consolas, monospace"
                            color: root.theme.textSecondary
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: root.theme.surface2

                        Rectangle {
                            height: parent.height
                            width: parent.width * (root.progressPct / 100.0)
                            radius: 4
                            color: root.theme.accent
                            Behavior on width { NumberAnimation { duration: 100 } }
                        }
                    }
                }

                // Log Box
                Rectangle {
                    Layout.fillWidth: true
                    height: 180
                    radius: 6
                    color: root.theme.isDark ? "#111113" : "#F4F5F7"
                    border.color: root.theme.border_
                    border.width: 1
                    clip: true

                    ListView {
                        id: logList
                        anchors.fill: parent
                        anchors.margins: 8
                        model: root.logLines
                        spacing: 2
                        onCountChanged: logList.positionViewAtEnd()

                        delegate: RowLayout {
                            width: logList.width
                            spacing: 8

                            Text {
                                text: "[" + modelData.time + "]"
                                font.pixelSize: 11
                                font.family: "Consolas, monospace"
                                color: root.theme.textMuted
                            }
                            Text {
                                text: modelData.text
                                font.pixelSize: 11
                                font.family: "Consolas, monospace"
                                font.weight: modelData.type === "success" || modelData.type === "error" ? Font.Bold : Font.Normal
                                color: modelData.type === "success" ? root.theme.success : (modelData.type === "error" ? root.theme.danger : (modelData.type === "warning" ? root.theme.warning : root.theme.textPrimary))
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAnywhere
                            }
                        }
                    }
                }
            }
        }

        Item { height: 20 }
    }

    ConfettiEffect { id: confetti }
    ToastNotification { id: toast; theme: root.theme }
}
