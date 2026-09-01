// ============================================================
// qml/pages/PhotoMatcherPage.qml
// Screen 2: Photo Remaining Matcher (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property var engine: typeof photoEngine !== "undefined" ? photoEngine : null
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
    required property var theme

    // Internal State
    property string targetDir: ""
    property var results: []
    property var stats: ({
        total: 0,
        matched: 0,
        unmatched: 0,
        duplicates: 0,
        errors: 0
    })
    property var preStats: ({
        dateFolders: 0,
        originalPhotos: 0,
        remainingPhotos: 0
    })
    property string searchQuery: ""
    property string statusFilter: "ALL"
    property string dateFilter: "ALL"

    property bool isScanning: false
    property bool isRenaming: false
    property bool hasScanned: false
    property real progressVal: 0.0
    property string progressMsg: ""
    property string currentFileMsg: ""

    // ── Backend Engine Connections ────────────────────────────────────────────
    Connections {
        target: root.engine
        ignoreUnknownSignals: true

        function onScanningChanged() {
            if (root.engine) root.isScanning = root.engine.scanning
        }
        function onRenamingChanged() {
            if (root.engine) root.isRenaming = root.engine.renaming
        }
        function onScanCompleted(res) {
            root.hasScanned = true
            root.results = res.all_items || res.items || []
            root.stats = {
                total: res.totalRemaining || (root.results ? root.results.length : 0),
                matched: res.totalUsed || 0,
                unmatched: res.totalMissing || 0,
                duplicates: res.totalDuplicates || 0,
                errors: res.totalErrors || 0
            }
            toast.show("Scan complete: " + (res.totalUsed || 0) + " matched / " + (res.totalMissing || 0) + " unmatched photos found.", "success")
        }
        function onScanError(msg) {
            toast.show("Scan error: " + msg, "danger")
        }
        function onPreStatsReady(ps) {
            var p = ps.pre_stats || ps || {}
            root.preStats = {
                dateFolders: p.date_folder_count !== undefined ? p.date_folder_count : (p.dateFolders || 0),
                originalPhotos: p.total_original_photos !== undefined ? p.total_original_photos : (p.originalPhotos || 0),
                remainingPhotos: p.total_remaining_photos !== undefined ? p.total_remaining_photos : (p.remainingPhotos || 0)
            }
        }
        function onRenameCompleted(successCount, errorCount, reportPath, skippedCount) {
            toast.show("✅ Renamed " + successCount + " files successfully · Report created in Document folder", "success")
            if (root.engine && root.targetDir) {
                root.engine.getPreStats(root.targetDir)
                root.engine.scan(root.targetDir)
            }
        }
        function onReportExported(path) {
            toast.show("📊 Report generated: " + path, "info")
        }
        function onError(msg) {
            toast.show("Error: " + msg, "danger")
        }
    }

    // ── Filtered Results Computation ──────────────────────────────────────────
    property var filteredResults: {
        var list = root.results || []
        if (root.searchQuery !== "") {
            var q = root.searchQuery.toLowerCase()
            list = list.filter(function(r) {
                return (r.filename || "").toLowerCase().includes(q) ||
                       (r.targetFolder || "").toLowerCase().includes(q) ||
                       (r.dateFolder || "").toLowerCase().includes(q)
            })
        }
        if (root.statusFilter !== "ALL") {
            list = list.filter(function(r) {
                return (r.status || "").toUpperCase() === root.statusFilter
            })
        }
        if (root.dateFilter !== "ALL") {
            list = list.filter(function(r) {
                return (r.dateFolder || "") === root.dateFilter
            })
        }
        return list
    }

    // ── Layout ────────────────────────────────────────────────────────────────
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
                    text: "Photo Status Tagger"
                    font.pixelSize: 22
                    font.weight: Font.Black
                    color: root.theme.textPrimary
                }
                Text {
                    text: "Scan and tag event photos with _U (Used / Matched) and _R (Remaining / Unused) status indicators."
                    font.pixelSize: 12
                    color: root.theme.textSecondary
                }
            }
            Item { Layout.fillWidth: true }
        }

        // ── 2. Directory & Metadata Section ───────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 16
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: dirCol.implicitHeight + 32

            ColumnLayout {
                id: dirCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 14

                Text {
                    text: "MASTER EVENT ROOT DIRECTORY"
                    font.pixelSize: 10
                    font.weight: Font.Black
                    font.letterSpacing: 1.2
                    color: root.theme.textMuted
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

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
                                text: root.targetDir || "Select master event root directory..."
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.targetDir ? root.theme.textPrimary : root.theme.textMuted
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
                                var chosen = root.dialogs.selectDirectory("Select Master Photo Directory")
                                if (chosen) {
                                    root.targetDir = chosen
                                    if (root.engine) {
                                        root.engine.getPreStats(chosen)
                                        root.engine.scan(chosen)
                                    }
                                }
                            }
                        }
                    }

                    StudioButton {
                        text: root.isScanning ? "Scanning..." : "Scan Directory"
                        iconText: "⚡"
                        variant: "primary"
                        btnSize: "md"
                        enabled: root.targetDir !== "" && !root.isScanning
                        loading: root.isScanning
                        theme: root.theme
                        onClicked: if (root.engine) root.engine.scan(root.targetDir)
                    }
                }

                // Horizontal Metadata Strip
                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: 8
                    color: root.theme.surface2
                    border.color: root.theme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 16

                        RowLayout {
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: root.theme.accent }
                            Text { text: String(root.preStats.dateFolders || 0); font.pixelSize: 12; font.weight: Font.Bold; font.family: "Consolas, monospace"; color: root.theme.accent }
                            Text { text: "DATE FOLDERS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }
                        }

                        Text { text: "•"; font.pixelSize: 10; color: root.theme.border_ }

                        RowLayout {
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: root.theme.success }
                            Text { text: String(root.preStats.originalPhotos || 0); font.pixelSize: 12; font.weight: Font.Bold; font.family: "Consolas, monospace"; color: root.theme.success }
                            Text { text: "MASTER PHOTOS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }
                        }

                        Text { text: "•"; font.pixelSize: 10; color: root.theme.border_ }

                        RowLayout {
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: root.theme.camB }
                            Text { text: String(root.preStats.remainingPhotos || 0); font.pixelSize: 12; font.weight: Font.Bold; font.family: "Consolas, monospace"; color: root.theme.camB }
                            Text { text: "REMAINING PHOTOS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }

        // ── 3. Match Summary Strip ────────────────────────────────────────────
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

                // Total Remaining Pill
                Rectangle {
                    height: 30
                    width: remRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.surface2
                    RowLayout {
                        id: remRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.total || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textPrimary }
                        Text { text: "Remaining"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textSecondary }
                    }
                }

                // Matched Pill
                Rectangle {
                    height: 30
                    width: matRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                    border.color: root.theme.isDark ? "#10B981" : "#A7F3D0"
                    border.width: 1
                    RowLayout {
                        id: matRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.matched || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.success }
                        Text { text: "Matched (_U)"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.success }
                    }
                }

                // Not Matched Pill
                Rectangle {
                    height: 30
                    width: unmatRow.implicitWidth + 18
                    radius: 7
                    color: root.theme.isDark ? "#4C0519" : "#FFF1F2"
                    border.color: root.theme.isDark ? "#F43F5E" : "#FECACA"
                    border.width: 1
                    RowLayout {
                        id: unmatRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.unmatched || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.danger }
                        Text { text: "Not Matched (_R)"; font.pixelSize: 11; font.weight: Font.Bold; color: root.theme.danger }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // ── 4. Compact Toolbar (Search, Filter, Export, Rename) ────────────────
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
                        placeholderText: "Search filenames, event folders, dates..."
                        font.pixelSize: 12
                        color: root.theme.textPrimary
                        background: Item {}
                        onTextChanged: root.searchQuery = text
                    }
                }
            }

            // Status Filter Dropdown
            ComboBox {
                id: statusCombo
                width: 145
                height: 38
                model: ["ALL", "MATCHED", "NOT_MATCHED", "DUPLICATE"]
                displayText: currentText === "ALL" ? "All Statuses" : currentText
                onActivated: root.statusFilter = currentText

                background: Rectangle {
                    radius: 8
                    color: root.theme.surface
                    border.color: root.theme.border_
                    border.width: 1
                }
                contentItem: Text {
                    leftPadding: 12
                    text: statusCombo.displayText
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
            }

            StudioButton {
                text: "Export CSV"
                iconText: "📊"
                variant: "glass"
                btnSize: "md"
                theme: root.theme
                onClicked: {
                    if (root.engine && root.targetDir) {
                        root.engine.exportReport("csv", root.targetDir + "/Document/Photo_Match_Report.csv")
                        toast.show("Report exported successfully", "success")
                    }
                }
            }

            StudioButton {
                text: root.isRenaming ? "Renaming..." : "Tag & Rename (_U / _R)"
                iconText: "🏷️"
                variant: "primary"
                btnSize: "md"
                enabled: root.results.length > 0 && !root.isRenaming
                loading: root.isRenaming
                theme: root.theme
                onClicked: {
                    if (root.engine) {
                        root.isRenaming = true
                        root.engine.rename()
                    }
                }
            }
        }

        // ── 5. Professional Results Table ─────────────────────────────────────
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
                        spacing: 10

                        Text { text: "STATUS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 110 }
                        Text { text: "ORIGINAL FILENAME"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 220 }
                        Text { text: "DATE FOLDER"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 130 }
                        Text { text: "PROPOSED NEW FILENAME"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: root.theme.borderSubtle
                    }
                }

                // Table Rows
                ListView {
                    id: resList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.filteredResults
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
                            spacing: 10

                            // Semantic Status Pill Badge
                            SemanticBadge {
                                Layout.preferredWidth: 104
                                theme: root.theme
                                type: (modelData.status === "MATCHED" || modelData.status === "Used") ? "matched"
                                    : "danger"
                                text: (modelData.status === "MATCHED" || modelData.status === "Used") ? "Matched (_U)"
                                    : "Missing (_R)"
                                showDot: true
                            }

                            // Original Filename
                            Text {
                                text: modelData.current_filename || modelData.original_name || modelData.filename || ""
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 220
                                elide: Text.ElideMiddle
                            }

                            // Date Folder
                            Text {
                                text: modelData.date_folder_name || modelData.dateFolder || "—"
                                font.pixelSize: 12
                                color: root.theme.textSecondary
                                Layout.preferredWidth: 130
                                elide: Text.ElideRight
                            }

                            // Proposed New Filename
                            Text {
                                text: modelData.proposed_new_filename || modelData.target_name || modelData.targetFolder || "—"
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                font.weight: Font.DemiBold
                                color: (modelData.status === "MATCHED" || modelData.status === "Used") ? root.theme.success : root.theme.danger
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
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
                        rowCount: 6
                        cardHeight: 38
                        rowSpacing: 4
                    }

                    // Empty State
                    Item {
                        anchors.centerIn: parent
                        visible: !root.isScanning && root.filteredResults.length === 0
                        width: parent.width

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "No scan results"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Select a master directory and start a scan to begin."
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
        visible_: root.isScanning || root.isRenaming
        title: root.isScanning ? "Scanning master & remaining photos..." : "Renaming remaining photos..."
        message: root.progressMsg
        currentFile: root.currentFileMsg
        currentCount: Math.round(root.progressVal * (root.stats.total || 100))
        totalCount: root.stats.total || 0
        progress: root.progressVal
    }

    // ── Toast Notification ────────────────────────────────────────────────────
    ToastNotification { id: toast; theme: root.theme }
}
