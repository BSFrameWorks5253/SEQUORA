// ============================================================
// qml/pages/ThumbnailSeparatorPage.qml
// Screen: Recursive _P & _V Thumbnail Folder Structure Shifter
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    required property var theme
    property var engine: typeof thumbSeparatorEngine !== "undefined" ? thumbSeparatorEngine : (typeof thumbEngine !== "undefined" ? thumbEngine : null)
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null

    // State Variables
    property string sourceDir: ""
    property string destDir: ""
    property string actionMode: "copy" // "copy" | "move"
    property string typeFilter: "ALL"   // "ALL" | "PHOTO" | "VIDEO"
    property string searchQuery: ""

    property bool isScanning: engine ? engine.scanning : false
    property bool isProcessing: engine ? engine.isProcessing : false

    property var scanData: null
    property var items: []

    property real progressPct: 0
    property string currentFileMsg: ""
    property string speedMsg: ""
    property int currentCount: 0
    property int totalCount: 0

    // Filtered items computation
    property var filteredItems: {
        var list = root.items || []
        if (root.typeFilter === "PHOTO") {
            list = list.filter(function(it) { return it.type === "photo" })
        } else if (root.typeFilter === "VIDEO") {
            list = list.filter(function(it) { return it.type === "video" })
        }

        if (root.searchQuery !== "") {
            var q = root.searchQuery.toLowerCase()
            list = list.filter(function(it) {
                return (it.filename || "").toLowerCase().includes(q) ||
                       (it.relDir || "").toLowerCase().includes(q)
            })
        }
        return list
    }

    function formatBytes(bytes) {
        if (!bytes || bytes === 0) return "0 B"
        var k = 1024
        var sizes = ["B", "KB", "MB", "GB", "TB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i]
    }

    // Backend Signal Connections
    Connections {
        target: root.engine
        ignoreUnknownSignals: true

        function onScanCompleted(result) {
            root.scanData = result
            root.items = result.items || []
            var mb = (result.totalBytes / (1024 * 1024)).toFixed(1)
            toast.show("Scan complete: " + result.totalThumbnails + " thumbnails found (" + result.pCount + " _P, " + result.vCount + " _V, " + mb + " MB)", "success")
        }
        function onProgress(data) {
            root.currentCount = data.current || 0
            root.totalCount = data.total || 0
            root.currentFileMsg = data.current_file || ""
            root.speedMsg = (data.speed_mbps || 0) + " MB/s"
            root.progressPct = data.total > 0 ? (data.current / data.total) : 0.0
        }
        function onProcessingCompleted(result) {
            root.progressPct = 1.0
            toast.show("✅ Success! " + result.success_count + " thumbnails transferred by folder structure.", "success")
            if (root.engine && root.sourceDir) {
                root.engine.scanFolder(root.sourceDir)
            }
        }
        function onError(errMsg) {
            toast.show("Error: " + errMsg, "danger")
        }
    }

    // Main Layout
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
                    text: "Thumbnail Folder Structure Shifter"
                    font.pixelSize: 22
                    font.weight: Font.Black
                    color: root.theme.textPrimary
                }
                Text {
                    text: "Recursively extract _P (photo) & _V (video) thumbnails and shift them preserving the exact folder structure."
                    font.pixelSize: 12
                    color: root.theme.textSecondary
                }
            }
            Item { Layout.fillWidth: true }
        }

        // ── 2. Directory & Mode Setup Card ────────────────────────────────────
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

                    // Source Directory
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "SOURCE EVENT ROOT DIRECTORY"
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
                                    Text { text: "📁"; font.pixelSize: 13; opacity: 0.7 }
                                    Text {
                                        text: root.sourceDir || "Select source root directory containing event photos & videos..."
                                        font.pixelSize: 12
                                        font.family: "Consolas, monospace"
                                        color: root.sourceDir ? root.theme.textPrimary : root.theme.textMuted
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
                                        var c = root.dialogs.selectDirectory("Select Source Directory")
                                        if (c) {
                                            root.sourceDir = c
                                            if (!root.destDir) {
                                                root.destDir = c + "_Thumbnails"
                                            }
                                            if (root.engine) root.engine.scanFolder(c)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Destination Directory
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "DESTINATION THUMBNAILS ROOT"
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
                                    Text { text: "📦"; font.pixelSize: 13; opacity: 0.7 }
                                    Text {
                                        text: root.destDir || "Select destination directory for organized thumbnails..."
                                        font.pixelSize: 12
                                        font.family: "Consolas, monospace"
                                        color: root.destDir ? root.theme.textPrimary : root.theme.textMuted
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
                                        var c = root.dialogs.selectDirectory("Select Destination Thumbnails Directory")
                                        if (c) root.destDir = c
                                    }
                                }
                            }
                        }
                    }

                    // Action: Scan Now
                    ColumnLayout {
                        spacing: 6
                        Layout.alignment: Qt.AlignBottom

                        Text { text: "ACTION"; font.pixelSize: 10; font.weight: Font.Black; font.letterSpacing: 1.0; color: root.theme.textMuted }

                        StudioButton {
                            text: root.isScanning ? "Scanning..." : "Scan Thumbnails"
                            iconText: "⚡"
                            variant: "cyan"
                            btnSize: "md"
                            enabled: root.sourceDir !== "" && !root.isScanning
                            loading: root.isScanning
                            theme: root.theme
                            onClicked: {
                                if (root.engine) root.engine.scanFolder(root.sourceDir)
                            }
                        }
                    }
                }
            }
        }

        // ── 3. Live Telemetry Metric Strip ────────────────────────────────────
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

                // Total Thumbnails Pill
                Rectangle {
                    height: 30
                    width: totRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.surface2
                    RowLayout {
                        id: totRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.scanData ? root.scanData.totalThumbnails : 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textPrimary }
                        Text { text: "Thumbnails Found"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textSecondary }
                    }
                }

                // _P Photo Thumbnails Pill
                Rectangle {
                    height: 30
                    width: pRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.isDark ? "#261947" : "#F3EEFC"
                    border.color: root.theme.isDark ? "#8B5CF6" : "#DDD6FE"
                    border.width: 1
                    RowLayout {
                        id: pRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.scanData ? root.scanData.pCount : 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: "#8B5CF6" }
                        Text { text: "_P (Photo Thumbs)"; font.pixelSize: 11; font.weight: Font.Bold; color: "#8B5CF6" }
                    }
                }

                // _V Video Thumbnails Pill
                Rectangle {
                    height: 30
                    width: vRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                    border.color: root.theme.isDark ? "#10B981" : "#A7F3D0"
                    border.width: 1
                    RowLayout {
                        id: vRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.scanData ? root.scanData.vCount : 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: "#10B981" }
                        Text { text: "_V (Video Thumbs)"; font.pixelSize: 11; font.weight: Font.Bold; color: "#10B981" }
                    }
                }

                // Total Size Pill
                Rectangle {
                    height: 30
                    width: szRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.surface2
                    RowLayout {
                        id: szRow; anchors.centerIn: parent; spacing: 6
                        Text { text: root.formatBytes(root.scanData ? root.scanData.totalBytes : 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textPrimary }
                        Text { text: "Total Size"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textMuted }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // ── 4. Toolbar (Search, Filter, Mode) ──────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Search Field
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: root.theme.surface
                border.color: sInp.activeFocus ? root.theme.accent : root.theme.border_
                border.width: sInp.activeFocus ? 1.5 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text { text: "🔍"; font.pixelSize: 12; opacity: 0.6 }
                    TextField {
                        id: sInp
                        Layout.fillWidth: true
                        placeholderText: "Search thumbnail filenames or folder paths..."
                        font.pixelSize: 12
                        color: root.theme.textPrimary
                        background: Item {}
                        onTextChanged: root.searchQuery = text
                    }
                }
            }

            // Filter ComboBox
            ComboBox {
                id: typeCombo
                width: 145
                height: 38
                model: ["ALL", "PHOTO", "VIDEO"]
                displayText: currentText === "ALL" ? "All Types (_P & _V)" : (currentText === "PHOTO" ? "_P Photo Only" : "_V Video Only")
                onActivated: root.typeFilter = currentText

                background: Rectangle {
                    radius: 8
                    color: root.theme.surface
                    border.color: root.theme.border_
                    border.width: 1
                }
                contentItem: Text {
                    leftPadding: 12
                    text: typeCombo.displayText
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Mode Selector
            Rectangle {
                height: 38
                radius: 8
                color: root.theme.surface
                border.color: root.theme.border_
                border.width: 1
                implicitWidth: modeRow.implicitWidth + 24

                RowLayout {
                    id: modeRow
                    anchors.centerIn: parent
                    spacing: 10

                    Text { text: "MODE:"; font.pixelSize: 10; font.weight: Font.Black; font.letterSpacing: 1.0; color: root.theme.textMuted }

                    RadioButton {
                        text: "Copy"
                        checked: root.actionMode === "copy"
                        onClicked: root.actionMode = "copy"
                    }
                    RadioButton {
                        text: "Move"
                        checked: root.actionMode === "move"
                        onClicked: root.actionMode = "move"
                    }
                }
            }

            // Primary Execute Button
            StudioButton {
                text: root.isProcessing ? "Shifting..." : (root.actionMode === "copy" ? "Copy Thumbnails by Structure" : "Move Thumbnails by Structure")
                iconText: "🚀"
                variant: "cyan"
                btnSize: "md"
                enabled: root.items.length > 0 && root.destDir !== "" && !root.isProcessing
                loading: root.isProcessing
                theme: root.theme
                onClicked: {
                    if (root.engine) {
                        root.engine.executeTransfer(root.sourceDir, root.destDir, root.actionMode, root.filteredItems)
                    }
                }
            }
        }

        // ── 5. Results Preview Table ──────────────────────────────────────────
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

                        Text { text: "TYPE"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 120 }
                        Text { text: "THUMBNAIL FILENAME"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 240 }
                        Text { text: "SUBFOLDER STRUCTURE (REL DIR)"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                        Text { text: "SIZE"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
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
                    id: thumbList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.filteredItems
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 42
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
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12

                            // Type Badge
                            Rectangle {
                                Layout.preferredWidth: 110
                                height: 24
                                radius: 6
                                color: modelData.type === "photo"
                                       ? (root.theme.isDark ? "#261947" : "#F3EEFC")
                                       : (root.theme.isDark ? "#064E3B" : "#ECFDF5")
                                border.color: modelData.type === "photo" ? "#8B5CF6" : "#10B981"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        text: modelData.type === "photo" ? "📸 _P Photo" : "🎬 _V Video"
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: modelData.type === "photo" ? "#8B5CF6" : "#10B981"
                                    }
                                }
                            }

                            // Filename
                            Text {
                                text: modelData.filename || ""
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 240
                                elide: Text.ElideMiddle
                            }

                            // Relative Subfolder Structure
                            Text {
                                text: modelData.relDir || "(Root Folder)"
                                font.pixelSize: 12
                                color: modelData.relDir ? root.theme.textSecondary : root.theme.textMuted
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            // File Size
                            Text {
                                text: root.formatBytes(modelData.sizeBytes)
                                font.pixelSize: 11
                                font.family: "Consolas, monospace"
                                color: root.theme.textMuted
                                Layout.preferredWidth: 90
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        MouseArea { id: rowHov; anchors.fill: parent; hoverEnabled: true }
                    }

                    // Empty State
                    Item {
                        anchors.centerIn: parent
                        visible: !root.isScanning && root.filteredItems.length === 0
                        width: parent.width

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "No thumbnails found"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Select a source directory containing _P and _V JPEG thumbnails to scan and organize."
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
    }

    // ── Operation Progress Overlay ────────────────────────────────────────────
    ProgressOverlay {
        theme: root.theme
        visible_: root.isProcessing
        title: (root.actionMode === "copy" ? "Copying" : "Moving") + " thumbnails by folder structure..."
        message: "Speed: " + (root.speedMsg || "Calculating...")
        currentFile: root.currentFileMsg
        currentCount: root.currentCount
        totalCount: root.totalCount
        progress: root.progressPct
    }

    // ── Toast Notification ────────────────────────────────────────────────────
    ToastNotification { id: toast; theme: root.theme }
}
