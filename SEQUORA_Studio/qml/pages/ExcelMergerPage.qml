// ============================================================
// qml/pages/ExcelMergerPage.qml
// Screen: 2-File High-Fidelity Excel Inventory Report Merger
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    required property var theme
    property var engine: typeof excelMergerEngine !== "undefined" ? excelMergerEngine : null
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null

    contentWidth: availableWidth
    clip: true

    // Internal State: Strictly 2 Files
    property string file1Path: ""
    property string file2Path: ""
    property string customOutputPath: ""
    property var mergeResult: null
    property bool isMerging: engine ? engine.isMerging : false
    property bool canMerge: file1Path !== "" && file2Path !== "" && !isMerging

    Connections {
        target: root.engine
        function onMergeCompleted(result) {
            root.mergeResult = result
            toast.show("✓ 2 Reports merged successfully into " + result.output_path, "success")
        }
        function onMergeFailed(errorMsg) {
            toast.show("⚠ " + errorMsg, "error")
        }
    }

    ColumnLayout {
        width: Math.min(1100, Math.max(320, root.availableWidth - 36))
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18

        Item { height: 10 }

        // ── Page Header ─────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                width: 44; height: 44
                radius: 10
                color: root.theme.isDark ? "#064E3B" : "#ECFDF5"
                border.color: root.theme.isDark ? "#059669" : "#A7F3D0"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "📑"
                    font.pixelSize: 22
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                Text {
                    text: "Excel Report Merger (2 Files)"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                }
                Text {
                    text: "Select exactly 2 Excel inventory workbooks to combine each sheet into a unified report with 100% style fidelity."
                    font.pixelSize: 13
                    color: root.theme.textSecondary
                }
            }
        }

        // ── 2-File Selection Container ──────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: twoFilesCol.implicitHeight + 32

            ColumnLayout {
                id: twoFilesCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Select Exactly 2 Excel Reports to Merge"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: root.theme.textPrimary
                        Layout.fillWidth: true
                    }

                    // Reset button
                    Rectangle {
                        visible: root.file1Path !== "" || root.file2Path !== ""
                        height: 28; width: 70; radius: 5
                        color: btnReset.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                        border.color: root.theme.border_
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Reset"
                            font.pixelSize: 11
                            color: root.theme.textMuted
                        }

                        MouseArea {
                            id: btnReset; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.file1Path = ""
                                root.file2Path = ""
                                root.mergeResult = null
                            }
                        }
                    }
                }

                // ── Slot 1: First Excel File ────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 68
                    radius: 6
                    color: root.file1Path !== "" ? (root.theme.isDark ? "#1C241E" : "#F0FDF4") : root.theme.surface2
                    border.color: root.file1Path !== "" ? (root.theme.isDark ? "#059669" : "#86EFAC") : root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        // Number Badge
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: root.file1Path !== "" ? root.theme.accent : (root.theme.isDark ? "#2A2A32" : "#E2E8F0")

                            Text {
                                anchors.centerIn: parent
                                text: "1"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.file1Path !== "" ? "#FFFFFF" : root.theme.textSecondary
                            }
                        }

                        // Text Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "First Excel Report (File 1)"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.theme.textMuted
                            }

                            Text {
                                text: root.file1Path !== "" ? root.file1Path.split(/[\/\\]/).pop() : "No file selected (e.g. 1448-03-12 _01M_Inventory_Report.xlsx)"
                                font.pixelSize: 13
                                font.weight: root.file1Path !== "" ? Font.DemiBold : Font.Normal
                                color: root.file1Path !== "" ? root.theme.textPrimary : root.theme.textMuted
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }

                        // Action Buttons
                        RowLayout {
                            spacing: 8

                            Rectangle {
                                height: 32; width: 120; radius: 6
                                color: btnPick1.containsMouse ? root.theme.surfaceElevated : root.theme.surface
                                border.color: root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "📂"; font.pixelSize: 12 }
                                    Text { text: root.file1Path !== "" ? "Change File 1" : "Choose File 1"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                }

                                MouseArea {
                                    id: btnPick1; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs && root.dialogs.selectOpenFile) {
                                            var p = root.dialogs.selectOpenFile("Select First Excel Report", "Excel Workbooks (*.xlsx *.xlsm)")
                                            if (p) root.file1Path = p
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: root.file1Path !== ""
                                width: 26; height: 26; radius: 4
                                color: rm1Hov.containsMouse ? root.theme.dangerSoft : "transparent"
                                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 10; color: rm1Hov.containsMouse ? root.theme.danger : root.theme.textMuted }
                                MouseArea {
                                    id: rm1Hov; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.file1Path = ""
                                }
                            }
                        }
                    }
                }

                // Divider Link
                Item {
                    Layout.fillWidth: true
                    height: 20
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Rectangle { width: 80; height: 1; color: root.theme.borderSubtle }
                        Text { text: "➕ Merge With"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.accent }
                        Rectangle { width: 80; height: 1; color: root.theme.borderSubtle }
                    }
                }

                // ── Slot 2: Second Excel File ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 68
                    radius: 6
                    color: root.file2Path !== "" ? (root.theme.isDark ? "#1C241E" : "#F0FDF4") : root.theme.surface2
                    border.color: root.file2Path !== "" ? (root.theme.isDark ? "#059669" : "#86EFAC") : root.theme.border_
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        // Number Badge
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: root.file2Path !== "" ? root.theme.accent : (root.theme.isDark ? "#2A2A32" : "#E2E8F0")

                            Text {
                                anchors.centerIn: parent
                                text: "2"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.file2Path !== "" ? "#FFFFFF" : root.theme.textSecondary
                            }
                        }

                        // Text Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Second Excel Report (File 2)"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.theme.textMuted
                            }

                            Text {
                                text: root.file2Path !== "" ? root.file2Path.split(/[\/\\]/).pop() : "No file selected (e.g. 1448-03-12 _02E_Inventory_Report.xlsx)"
                                font.pixelSize: 13
                                font.weight: root.file2Path !== "" ? Font.DemiBold : Font.Normal
                                color: root.file2Path !== "" ? root.theme.textPrimary : root.theme.textMuted
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }

                        // Action Buttons
                        RowLayout {
                            spacing: 8

                            Rectangle {
                                height: 32; width: 120; radius: 6
                                color: btnPick2.containsMouse ? root.theme.surfaceElevated : root.theme.surface
                                border.color: root.theme.border_
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "📂"; font.pixelSize: 12 }
                                    Text { text: root.file2Path !== "" ? "Change File 2" : "Choose File 2"; font.pixelSize: 11; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                }

                                MouseArea {
                                    id: btnPick2; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs && root.dialogs.selectOpenFile) {
                                            var p = root.dialogs.selectOpenFile("Select Second Excel Report", "Excel Workbooks (*.xlsx *.xlsm)")
                                            if (p) root.file2Path = p
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: root.file2Path !== ""
                                width: 26; height: 26; radius: 4
                                color: rm2Hov.containsMouse ? root.theme.dangerSoft : "transparent"
                                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 10; color: rm2Hov.containsMouse ? root.theme.danger : root.theme.textMuted }
                                MouseArea {
                                    id: rm2Hov; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.file2Path = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Sheets Information Preview ──────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: sheetInfoCol.implicitHeight + 32

            ColumnLayout {
                id: sheetInfoCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Unified Sheet Structure & Style Preservation"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                }

                GridLayout {
                    columns: parent.width > 700 ? 3 : 1
                    columnSpacing: 12
                    rowSpacing: 12
                    Layout.fillWidth: true

                    // Card 1: Missing Files
                    Rectangle {
                        Layout.fillWidth: true; height: 76; radius: 6
                        color: root.theme.surface2; border.color: root.theme.borderSubtle; border.width: 1
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 4
                            RowLayout {
                                spacing: 6
                                Text { text: "🔴"; font.pixelSize: 11 }
                                Text { text: "Missing Files"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                            }
                            Text {
                                text: "Concatenates rows across reports with red/pink highlight preservation."
                                font.pixelSize: 11; color: root.theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true
                            }
                        }
                    }

                    // Card 2: Folder Structure
                    Rectangle {
                        Layout.fillWidth: true; height: 76; radius: 6
                        color: root.theme.surface2; border.color: root.theme.borderSubtle; border.width: 1
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 4
                            RowLayout {
                                spacing: 6
                                Text { text: "📂"; font.pixelSize: 11 }
                                Text { text: "Folder Structure"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                            }
                            Text {
                                text: "Combines subfolder tree columns side-by-side with exact widths."
                                font.pixelSize: 11; color: root.theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true
                            }
                        }
                    }

                    // Card 3: Camera Summary
                    Rectangle {
                        Layout.fillWidth: true; height: 76; radius: 6
                        color: root.theme.surface2; border.color: root.theme.borderSubtle; border.width: 1
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 4
                            RowLayout {
                                spacing: 6
                                Text { text: "🎥"; font.pixelSize: 11 }
                                Text { text: "Camera Summary"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                            }
                            Text {
                                text: "Consolidates clip lists per camera and calculates total found/missing."
                                font.pixelSize: 11; color: root.theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        // ── Action Section ──────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Merge Action Button
            Rectangle {
                Layout.fillWidth: true
                height: 46
                radius: 8
                color: root.isMerging ? root.theme.surface2 : (btnMergeHov.containsMouse ? root.theme.accentHover : root.theme.accent)
                opacity: root.canMerge ? 1.0 : 0.4
                enabled: root.canMerge

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: root.isMerging ? "⏳" : "⚡"
                        font.pixelSize: 15
                    }
                    Text {
                        text: root.isMerging ? "Merging 2 Workbooks & Styles..." : (root.canMerge ? "Merge These 2 Excel Reports Now" : "Select Both File 1 & File 2 to Merge")
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }

                MouseArea {
                    id: btnMergeHov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!root.canMerge || !root.engine) return
                        root.engine.mergeFiles([root.file1Path, root.file2Path], root.customOutputPath)
                    }
                }
            }
        }

        // ── Results Summary Card ────────────────────────────────────
        Rectangle {
            visible: root.mergeResult !== null
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.isDark ? "#065F46" : "#A7F3D0"
            border.width: 1
            implicitHeight: resCol.implicitHeight + 32

            ColumnLayout {
                id: resCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "✓"; font.pixelSize: 16; font.weight: Font.Bold; color: root.theme.success }
                    Text {
                        text: "2 Workbooks Merged Successfully!"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: root.theme.textPrimary
                    }
                }

                // Metrics Grid
                GridLayout {
                    columns: parent.width > 600 ? 4 : 2
                    Layout.fillWidth: true
                    columnSpacing: 10
                    rowSpacing: 10

                    Rectangle {
                        Layout.fillWidth: true; height: 58; radius: 6; color: root.theme.surface2
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Files Merged"; font.pixelSize: 10; color: root.theme.textMuted }
                            Text { text: "2 Files"; font.pixelSize: 15; font.weight: Font.Bold; color: root.theme.accent }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 58; radius: 6; color: root.theme.surface2
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Missing Files"; font.pixelSize: 10; color: root.theme.textMuted }
                            Text { text: String(root.mergeResult ? root.mergeResult.missing_files_count : 0); font.pixelSize: 15; font.weight: Font.Bold; color: root.theme.danger }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 58; radius: 6; color: root.theme.surface2
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Folder Trees"; font.pixelSize: 10; color: root.theme.textMuted }
                            Text { text: String(root.mergeResult ? root.mergeResult.folder_columns_count : 0); font.pixelSize: 15; font.weight: Font.Bold; color: root.theme.info }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 58; radius: 6; color: root.theme.surface2
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 2
                            Text { text: "Camera Clips"; font.pixelSize: 10; color: root.theme.textMuted }
                            Text { text: String(root.mergeResult ? root.mergeResult.camera_summary_found : 0); font.pixelSize: 15; font.weight: Font.Bold; color: root.theme.success }
                        }
                    }
                }

                // File Path and Action Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "Saved to: " + (root.mergeResult ? root.mergeResult.output_path : "")
                        font.pixelSize: 11
                        font.family: "Consolas, monospace"
                        color: root.theme.textSecondary
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                    }

                    // Open File Button
                    Rectangle {
                        height: 32; width: 140; radius: 6
                        color: btnOpenExcel.containsMouse ? root.theme.accentHover : root.theme.accent
                        RowLayout {
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "📊"; font.pixelSize: 12 }
                            Text { text: "Open Excel File"; font.pixelSize: 12; font.weight: Font.Bold; color: "#FFFFFF" }
                        }
                        MouseArea {
                            id: btnOpenExcel; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.mergeResult && root.dialogs) {
                                    root.dialogs.openPath(root.mergeResult.output_path)
                                }
                            }
                        }
                    }

                    // Open Folder Button
                    Rectangle {
                        height: 32; width: 130; radius: 6
                        color: btnOpenFolder.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                        border.color: root.theme.border_
                        border.width: 1
                        RowLayout {
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "📂"; font.pixelSize: 12 }
                            Text { text: "Show in Folder"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                        }
                        MouseArea {
                            id: btnOpenFolder; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.mergeResult && root.dialogs) {
                                    var f = root.mergeResult.output_path.split(/[\/\\]/).slice(0, -1).join("/")
                                    root.dialogs.openPath(f)
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { height: 20 }
    }

    ToastNotification { id: toast; theme: root.theme }
}
