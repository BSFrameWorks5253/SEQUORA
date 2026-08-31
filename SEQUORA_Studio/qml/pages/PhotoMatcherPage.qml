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

        function onScanStarted() {
            root.isScanning = true
            root.progressVal = 0.0
            root.progressMsg = "Indexing master and remaining photos..."
        }
        function onScanProgress(current, total, filename) {
            root.progressVal = total > 0 ? (current / total) : 0.0
            root.currentFileMsg = filename
        }
        function onScanFinished(res, st) {
            root.isScanning = false
            root.hasScanned = true
            root.results = res || []
            root.stats = st || { total: 0, matched: 0, unmatched: 0, duplicates: 0, errors: 0 }
            toast.show("Scan complete: " + (st ? st.matched : 0) + " matched photos found.", "success")
        }
        function onScanError(msg) {
            root.isScanning = false
            toast.show("Scan error: " + msg, "danger")
        }
        function onPreStatsReady(ps) {
            root.preStats = ps || { dateFolders: 0, originalPhotos: 0, remainingPhotos: 0 }
        }
        function onRenameFinished(successCount, errorCount) {
            root.isRenaming = false
            toast.show("✅ Renamed " + successCount + " files successfully · Report created in Document folder", "success")
            if (root.engine && root.targetDir) root.engine.scan(root.targetDir)
        }
        function onRenameProgress(current, total, filename) {
            root.progressVal = total > 0 ? (current / total) : 0.0
            root.currentFileMsg = filename
        }
        function onRenameError(msg) {
            root.isRenaming = false
            toast.show("Rename error: " + msg, "danger")
        }
        function onReportExported(path) {
            toast.show("📊 Report generated: " + path, "info")
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
        ColumnLayout {
            spacing: 2
            Text {
                text: "Photo Remaining Matcher"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: root.theme.textPrimary
            }
            Text {
                text: "Match remaining photos against their master event folders."
                font.pixelSize: 13
                color: root.theme.textSecondary
            }
        }

        // ── 2. Directory & Metadata Section ───────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: dirCol.implicitHeight + 28

            ColumnLayout {
                id: dirCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                Text {
                    text: "MASTER DIRECTORY"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                    color: root.theme.textMuted
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: root.theme.surfaceElevated
                        border.color: root.theme.border_
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text { text: "📁"; font.pixelSize: 12; opacity: 0.7 }

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

                    // Browse Button
                    Rectangle {
                        width: 90
                        height: 36
                        radius: 6
                        color: brwHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
                        border.color: brwHov.containsMouse ? root.theme.borderHover : root.theme.border_
                        border.width: 1
                        scale: brwHov.pressed ? 0.96 : (brwHov.containsMouse ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Change"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: root.theme.textPrimary
                        }

                        MouseArea {
                            id: brwHov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.dialogs) {
                                    var chosen = root.dialogs.chooseDirectory("Select Master Photo Directory", root.targetDir)
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
                    }

                    // Scan Action Button
                    Rectangle {
                        width: 105
                        height: 36
                        radius: 6
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: scnHov.containsMouse ? "#8B5CF6" : "#7C5CBF" }
                            GradientStop { position: 1.0; color: scnHov.containsMouse ? "#7C5CBF" : "#6D48C5" }
                        }
                        enabled: root.targetDir !== "" && !root.isScanning
                        scale: scnHov.pressed ? 0.96 : (scnHov.containsMouse ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.isScanning ? "Scanning..." : "⚡ Scan Now"
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: scnHov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: if (parent.enabled && root.engine) root.engine.scan(root.targetDir)
                        }
                    }
                }

                // Horizontal Metadata Strip
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: root.theme.surface2
                    border.color: root.theme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 16

                        RowLayout {
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: "#6366F1" }
                            Text { text: String(root.preStats.dateFolders || 0); font.pixelSize: 12; font.weight: Font.Bold; font.family: "Consolas, monospace"; color: "#6366F1" }
                            Text { text: "DATE FOLDERS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }
                        }

                        Text { text: "•"; font.pixelSize: 10; color: root.theme.border_ }

                        RowLayout {
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: "#059669" }
                            Text { text: String(root.preStats.originalPhotos || 0); font.pixelSize: 12; font.weight: Font.Bold; font.family: "Consolas, monospace"; color: "#059669" }
                            Text { text: "MASTER PHOTOS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }
                        }

                        Text { text: "•"; font.pixelSize: 10; color: root.theme.border_ }

                        RowLayout {
                            spacing: 6
                            Rectangle { width: 6; height: 6; radius: 3; color: "#DB2777" }
                            Text { text: String(root.preStats.remainingPhotos || 0); font.pixelSize: 12; font.weight: Font.Bold; font.family: "Consolas, monospace"; color: "#DB2777" }
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

                // Total Remaining Pill
                Rectangle {
                    height: 28
                    width: remRow.implicitWidth + 16
                    radius: 5
                    color: root.theme.surface2
                    RowLayout {
                        id: remRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.total || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textPrimary }
                        Text { text: "Remaining"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textSecondary }
                    }
                }

                // Matched Pill
                Rectangle {
                    height: 28
                    width: matRow.implicitWidth + 16
                    radius: 5
                    color: "#ECFDF5"
                    border.color: "#A7F3D0"
                    border.width: 1
                    RowLayout {
                        id: matRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.matched || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: "#059669" }
                        Text { text: "Matched (_U)"; font.pixelSize: 11; font.weight: Font.Bold; color: "#059669" }
                    }
                }

                // Not Matched Pill
                Rectangle {
                    height: 28
                    width: unmatRow.implicitWidth + 16
                    radius: 5
                    color: "#FEF2F2"
                    border.color: "#FECACA"
                    border.width: 1
                    RowLayout {
                        id: unmatRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.unmatched || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: "#DC2626" }
                        Text { text: "Not Matched (_R)"; font.pixelSize: 11; font.weight: Font.Bold; color: "#DC2626" }
                    }
                }

                // Duplicates Pill
                Rectangle {
                    height: 28
                    width: dupRow.implicitWidth + 16
                    radius: 5
                    color: "#FFFBEB"
                    border.color: "#FDE68A"
                    border.width: 1
                    RowLayout {
                        id: dupRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.duplicates || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: "#D97706" }
                        Text { text: "Duplicates"; font.pixelSize: 11; font.weight: Font.Bold; color: "#D97706" }
                    }
                }

                // Errors Pill
                Rectangle {
                    height: 28
                    width: errRow.implicitWidth + 16
                    radius: 5
                    color: root.theme.surface2
                    RowLayout {
                        id: errRow; anchors.centerIn: parent; spacing: 6
                        Text { text: String(root.stats.errors || 0); font.pixelSize: 12; font.weight: Font.ExtraBold; font.family: "Consolas, monospace"; color: root.theme.textMuted }
                        Text { text: "Errors"; font.pixelSize: 11; color: root.theme.textMuted }
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
                radius: 6
                color: root.theme.surface
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
                    radius: 6
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

            // Export Report Action
            Rectangle {
                width: 120
                height: 38
                radius: 6
                color: expHov.containsMouse ? root.theme.surface2 : root.theme.surface
                border.color: expHov.containsMouse ? root.theme.accent : root.theme.border_
                border.width: 1
                scale: expHov.pressed ? 0.96 : (expHov.containsMouse ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "📊"; font.pixelSize: 11 }
                    Text {
                        text: "Export Report"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: expHov.containsMouse ? root.theme.accent : root.theme.textPrimary
                    }
                }

                MouseArea {
                    id: expHov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.engine && root.targetDir) {
                            var expPath = root.engine.exportReport(root.targetDir)
                            toast.show("Report exported to " + expPath, "success")
                        }
                    }
                }
            }

            // Rename Remaining Photos Primary Action
            Rectangle {
                width: 210
                height: 38
                radius: 6
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: renHov.containsMouse ? "#8B5CF6" : "#7C5CBF" }
                    GradientStop { position: 1.0; color: renHov.containsMouse ? "#7C5CBF" : "#6D48C5" }
                }
                enabled: root.results.length > 0 && !root.isRenaming
                scale: renHov.pressed ? 0.96 : (renHov.containsMouse ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "🏷️"; font.pixelSize: 12 }
                    Text {
                        text: root.isRenaming ? "Renaming Files..." : "Rename Remaining Photos"
                        font.pixelSize: 12
                        font.weight: Font.ExtraBold
                        color: "#FFFFFF"
                    }
                }

                MouseArea {
                    id: renHov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (parent.enabled && root.engine) {
                            root.isRenaming = true
                            root.engine.rename()
                        }
                    }
                }
            }
        }

        // ── 5. Professional Results Table ─────────────────────────────────────
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
                        spacing: 10

                        Text { text: "STATUS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 100 }
                        Text { text: "FILE NAME"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 200 }
                        Text { text: "DATE"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 110 }
                        Text { text: "MASTER FOLDER"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                        Text { text: "MATCH TYPE"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 130 }
                        Text { text: "ACTION"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: root.theme.border_
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
                        height: 40
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
                            spacing: 10

                            // Semantic Status Pill Badge
                            SemanticBadge {
                                Layout.preferredWidth: 96
                                theme: root.theme
                                type: modelData.status === "MATCHED" ? "matched"
                                    : modelData.status === "NOT_MATCHED" ? "danger"
                                    : "mismatch"
                                text: modelData.status === "MATCHED" ? "Matched"
                                    : modelData.status === "NOT_MATCHED" ? "Unmatched"
                                    : "Duplicate"
                                showDot: true
                            }

                            // Filename
                            Text {
                                text: modelData.filename || ""
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 200
                                elide: Text.ElideMiddle
                            }

                            // Date
                            Text {
                                text: modelData.dateFolder || "—"
                                font.pixelSize: 12
                                color: root.theme.textSecondary
                                Layout.preferredWidth: 110
                                elide: Text.ElideRight
                            }

                            // Master Folder
                            Text {
                                text: modelData.targetFolder || "—"
                                font.pixelSize: 12
                                color: root.theme.textSecondary
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
                            }

                            // Match Type
                            Text {
                                text: modelData.matchType || "Exact filename"
                                font.pixelSize: 11
                                color: root.theme.textMuted
                                Layout.preferredWidth: 130
                            }

                            // Action arrow
                            Text {
                                text: "→"
                                font.pixelSize: 12
                                color: rowHov.containsMouse ? root.theme.accent : root.theme.textMuted
                                Layout.preferredWidth: 50
                                horizontalAlignment: Text.AlignRight
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
