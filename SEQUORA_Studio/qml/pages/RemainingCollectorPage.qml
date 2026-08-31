// ============================================================
// qml/pages/RemainingCollectorPage.qml
// Screen 5: Remaining Photos Shifter (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property var engine: typeof remainingEngine !== "undefined" ? remainingEngine : null
    property var dialogs: typeof nativeDialogs !== "undefined" ? nativeDialogs : null
    required property var theme

    property string sourceDir: ""
    property string destDir: ""
    property var manifest: []

    property bool isScanning: false
    property bool isShifting: false
    property real progressVal: 0.0
    property string currentFileMsg: ""

    // ── Backend Connections ───────────────────────────────────────────────────
    Connections {
        target: root.engine
        ignoreUnknownSignals: true

        function onScanStarted() { root.isScanning = true; root.progressVal = 0.0 }
        function onScanProgress(current, total, filename) {
            root.progressVal = total > 0 ? (current / total) : 0.0
            root.currentFileMsg = filename
        }
        function onScanFinished(items) {
            root.isScanning = false
            root.manifest = items || []
            toast.show("Found " + (items ? items.length : 0) + " date folders with remaining photos.", "success")
        }
        function onShiftFinished(count) {
            root.isShifting = false
            toast.show("✅ " + count + " remaining photo folders consolidated successfully.", "success")
        }
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
                text: "Remaining Photos Shifter"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: root.theme.textPrimary
            }
            Text {
                text: "Collect scattered Remaining Photos folders into a consolidated date structure."
                font.pixelSize: 13
                color: root.theme.textSecondary
            }
        }

        // ── 2. Source & Destination Setup ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 8
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: shiftDirCol.implicitHeight + 28

            ColumnLayout {
                id: shiftDirCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Source
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { text: "SOURCE DIRECTORY"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }

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
                                    Text { text: "📁"; font.pixelSize: 12; opacity: 0.7 }
                                    Text {
                                        text: root.sourceDir || "Select incoming events directory..."
                                        font.pixelSize: 12
                                        font.family: "Consolas, monospace"
                                        color: root.sourceDir ? root.theme.textPrimary : root.theme.textMuted
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            Rectangle {
                                width: 80; height: 36; radius: 6
                                color: sChgHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
                                border.color: root.theme.border_; border.width: 1
                                Text { anchors.centerIn: parent; text: "Change"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                MouseArea {
                                    id: sChgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs) {
                                            var c = root.dialogs.chooseDirectory("Select Source Directory", root.sourceDir)
                                            if (c) root.sourceDir = c
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Destination
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { text: "DESTINATION DIRECTORY"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted }

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
                                    Text { text: "📦"; font.pixelSize: 12; opacity: 0.7 }
                                    Text {
                                        text: root.destDir || "Select consolidated Remaining Photos destination..."
                                        font.pixelSize: 12
                                        font.family: "Consolas, monospace"
                                        color: root.destDir ? root.theme.textPrimary : root.theme.textMuted
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            Rectangle {
                                width: 80; height: 36; radius: 6
                                color: dChgHov.containsMouse ? root.theme.surface2 : root.theme.surfaceElevated
                                border.color: root.theme.border_; border.width: 1
                                Text { anchors.centerIn: parent; text: "Change"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.theme.textPrimary }
                                MouseArea {
                                    id: dChgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.dialogs) {
                                            var c = root.dialogs.chooseDirectory("Select Destination Directory", root.destDir)
                                            if (c) root.destDir = c
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Scan Action Button
                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        width: 100
                        height: 36
                        radius: 6
                        color: shScnHov.containsMouse ? root.theme.accentHover : root.theme.accent
                        enabled: root.sourceDir !== "" && !root.isScanning

                        Text {
                            anchors.centerIn: parent
                            text: root.isScanning ? "Scanning..." : "Scan Manifest"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: shScnHov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: if (parent.enabled && root.engine) root.engine.scan(root.sourceDir)
                        }
                    }
                }
            }
        }

        // ── 3. Date Manifest Table ────────────────────────────────────────────
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

                        Text { text: "DATE"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 160 }
                        Text { text: "FILES FOUND"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 120 }
                        Text { text: "DESTINATION"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.fillWidth: true }
                        Text { text: "STATUS"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textMuted; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: root.theme.border_
                    }
                }

                // Empty State
                Item {
                    visible: root.manifest.length === 0
                    Layout.fillWidth: true
                    height: 160

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "No date folders scanned"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: root.theme.textPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Select Source and Destination directories above, then click 'Scan Manifest' to build the date folder transfer tree."
                            font.pixelSize: 12
                            color: root.theme.textMuted
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Table Rows
                ListView {
                    id: manList
                    visible: root.manifest.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.manifest
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 40
                        color: mHov.containsMouse ? root.theme.surface2 : "transparent"

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

                            Text {
                                text: modelData.date || modelData.dateFolderName || "Date"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 160
                            }

                            Text {
                                text: String(modelData.files || modelData.fileCount || 0)
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textPrimary
                                Layout.preferredWidth: 120
                            }

                            Text {
                                text: modelData.dest || (root.destDir ? (root.destDir + "/" + (modelData.date || "")) : "—")
                                font.pixelSize: 12
                                font.family: "Consolas, monospace"
                                color: root.theme.textSecondary
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                height: 22
                                radius: 4
                                color: root.theme.successSoft

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.status || "Ready"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: root.theme.success
                                }
                            }
                        }

                        MouseArea { id: mHov; anchors.fill: parent; hoverEnabled: true }
                    }
                }
            }
        }

        // ── 4. Execution Footer Bar ───────────────────────────────────────────
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

                Text {
                    text: (root.manifest.length > 0 ? root.manifest.length : 3) + " folders ready"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.theme.textPrimary
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 165
                    height: 38
                    radius: 6
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: sftHov.containsMouse ? "#EC4899" : "#DB2777" }
                        GradientStop { position: 1.0; color: sftHov.containsMouse ? "#DB2777" : "#BE185D" }
                    }
                    enabled: !root.isShifting
                    scale: sftHov.pressed ? 0.96 : (sftHov.containsMouse ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "📦"; font.pixelSize: 12 }
                        Text {
                            text: root.isShifting ? "Shifting..." : "Start Shift →"
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: sftHov; anchors.fill: parent; hoverEnabled: true
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (parent.enabled && root.engine) {
                                root.isShifting = true
                                root.engine.shift(root.sourceDir, root.destDir)
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
        visible_: root.isShifting
        title: "Moving Remaining Photos..."
        message: root.currentFileMsg
        currentCount: Math.round(root.progressVal * 221)
        totalCount: 221
        progress: root.progressVal
    }

    // ── Toast Notification ────────────────────────────────────────────────────
    ToastNotification { id: toast; theme: root.theme }
}
