// ============================================================
// qml/pages/OverviewPage.qml
// SEQUORA Studio — Ultra-Modern Creative Production Command Center
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    required property var theme
    property var toolsModel: [
        { key: "pvSeparator",        icon: "box",    label: "PV Media Ingest",     color: "#06B6D4", bgSoft: "#F0F9FF", desc: "32x RAW Extraction" },
        { key: "photoMatcher",       icon: "photo",  label: "Photo Matcher",       color: "#8B5CF6", bgSoft: "#F3EEFC", desc: "_U & _R Tagging" },
        { key: "videoTransfer",      icon: "video",  label: "Video Sync",          color: "#10B981", bgSoft: "#ECFDF5", desc: "Sequence Pairing" },
        { key: "remainingCollector", icon: "layers", label: "Remaining Shifter",   color: "#EC4899", bgSoft: "#FDF2F8", desc: "Consolidation" },
        { key: "excelMerger",        icon: "report", label: "Excel Merger",        color: "#F59E0B", bgSoft: "#FFFBEB", desc: "Delivery Package" }
    ]
    signal navigate(string pageKey)

    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        width: Math.min(1180, parent.width - 48)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24

        Item { height: 4 }

        // ── 1. Hero Studio Command Header ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 140
            radius: 20
            color: root.theme.surfaceElevated
            border.color: root.theme.border_
            border.width: 1
            clip: true

            // Glowing top iridescent border
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#8B5CF6" }
                    GradientStop { position: 0.25; color: "#06B6D4" }
                    GradientStop { position: 0.50; color: "#10B981" }
                    GradientStop { position: 0.75; color: "#F59E0B" }
                    GradientStop { position: 1.0; color: "#EC4899" }
                }
            }

            // Subtle Background Radial Glow
            Rectangle {
                width: 320; height: 320; radius: 160
                x: parent.width - 240
                y: -120
                color: root.theme.isDark ? "#8B5CF6" : "#E0E7FF"
                opacity: root.theme.isDark ? 0.12 : 0.4
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            width: 8; height: 8; radius: 4
                            color: root.theme.success

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 0.3; duration: 900; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 0.3; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
                            }
                        }
                        Text {
                            text: "SEQUORA COMMAND CENTER"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            font.letterSpacing: 1.6
                            color: root.theme.accent
                        }
                    }

                    Text {
                        text: "Creative Production & Multi-Camera Workflow"
                        font.pixelSize: 22
                        font.weight: Font.Black
                        font.letterSpacing: -0.3
                        color: root.theme.textPrimary
                    }

                    Text {
                        text: "Automated media pairing, RAW separation, photo synchronization, and cloud asset distribution."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                    }
                }

                // Quick Launch Actions
                RowLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    StudioButton {
                        text: "Photo Matcher"
                        iconText: "📸"
                        variant: "primary"
                        btnSize: "md"
                        theme: root.theme
                        onClicked: root.navigate("photoMatcher")
                    }

                    StudioButton {
                        text: "Video Matcher"
                        iconText: "🎬"
                        variant: "success"
                        btnSize: "md"
                        theme: root.theme
                        onClicked: root.navigate("videoTransfer")
                    }
                }
            }
        }

        // ── 2. Real-Time Telemetry HUD Metric Cards ───────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            StatCard {
                label: "PHOTO MATCHES"
                value: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities)
                       ? activityEngine.activities.filter(a => a.tool && a.tool.includes("Photo")).length : 0
                accent: "purple"
                theme: root.theme
            }

            StatCard {
                label: "VIDEO CLIPS PAIRED"
                value: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities)
                       ? activityEngine.activities.filter(a => a.tool && a.tool.includes("Video")).length : 0
                accent: "green"
                theme: root.theme
            }

            StatCard {
                label: "MEDIA EXTRACTIONS"
                value: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities)
                       ? activityEngine.activities.filter(a => a.tool && a.tool.includes("PV") || a.tool && a.tool.includes("Remaining")).length : 0
                accent: "cyan"
                theme: root.theme
            }

            StatCard {
                label: "REPORTS MERGED"
                value: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.reports)
                       ? activityEngine.reports.length : 0
                accent: "amber"
                theme: root.theme
            }
        }

        // ── 3. Interactive Workflow Production Pipeline ───────────────────────
        Rectangle {
            Layout.fillWidth: true
            radius: 18
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1
            implicitHeight: pipeCol.implicitHeight + 36

            ColumnLayout {
                id: pipeCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 18
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "PRODUCTION PIPELINE WORKFLOW"
                        font.pixelSize: 11
                        font.weight: Font.ExtraBold
                        font.letterSpacing: 1.4
                        color: root.theme.textMuted
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Click any stage to execute tool"
                        font.pixelSize: 11
                        color: root.theme.accent
                        font.weight: Font.DemiBold
                    }
                }

                // Responsive Interactive Workflow Journey
                GridLayout {
                    id: pipeGrid
                    Layout.fillWidth: true
                    columns: pipeCol.width > 920 ? 5 : (pipeCol.width > 580 ? 3 : 2)
                    columnSpacing: 10
                    rowSpacing: 10

                    Repeater {
                        model: root.toolsModel

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 120
                            height: 74
                            radius: 12
                            color: stgHov.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                            border.color: stgHov.containsMouse ? modelData.color : root.theme.borderSubtle
                            border.width: 1.5
                            scale: stgHov.pressed ? 0.97 : (stgHov.containsMouse ? 1.02 : 1.0)
                            y: stgHov.containsMouse ? -2 : 0
                            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                            Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Rectangle {
                                    width: 32; height: 32; radius: 8
                                    color: root.theme.isDark ? Qt.rgba(0.1, 0.1, 0.15, 0.9) : modelData.bgSoft
                                    border.color: modelData.color
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: String(index + 1)
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                        color: modelData.color
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.label || ""
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: root.theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: modelData.desc || "Studio Tool"
                                        font.pixelSize: 9
                                        color: root.theme.textMuted
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            MouseArea {
                                id: stgHov
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigate(modelData.key)
                            }
                        }
                    }
                }
            }
        }

        // ── 4. Lower Two-Column Grid: Activity Stream & Cloud Status ──────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Left: Live Event Stream (60% width)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 60
                radius: 18
                color: root.theme.surface
                border.color: root.theme.border_
                border.width: 1
                implicitHeight: actCol.implicitHeight + 36

                ColumnLayout {
                    id: actCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "LIVE PRODUCTION AUDIT FEED"
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                            font.letterSpacing: 1.2
                            color: root.theme.textMuted
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "View All History →"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.theme.accent
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigate("activity")
                            }
                        }
                    }

                    // Empty State
                    Item {
                        visible: !(typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities && activityEngine.activities.length > 0)
                        Layout.fillWidth: true
                        height: 100

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "No engine operations logged yet"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Execute any tool above to view live audit traces and timing."
                                font.pixelSize: 11
                                color: root.theme.textMuted
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Repeater {
                        model: (typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities) ? activityEngine.activities.slice(0, 5) : []

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: 8
                            color: actHov.containsMouse ? root.theme.surface2 : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Text {
                                    text: modelData.time || ""
                                    font.pixelSize: 11
                                    font.family: "Consolas, monospace"
                                    color: root.theme.textMuted
                                    Layout.preferredWidth: 65
                                }

                                Rectangle {
                                    height: 22
                                    width: toolBadgeTxt.implicitWidth + 12
                                    radius: 6
                                    color: modelData.bg || root.theme.surface2

                                    Text {
                                        id: toolBadgeTxt
                                        anchors.centerIn: parent
                                        text: modelData.tool || ""
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: modelData.color || root.theme.accent
                                    }
                                }

                                Text {
                                    text: modelData.desc || modelData.action || ""
                                    font.pixelSize: 12
                                    color: root.theme.textSecondary
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color: modelData.color || root.theme.accent
                                }
                            }

                            MouseArea { id: actHov; anchors.fill: parent; hoverEnabled: true }
                        }
                    }
                }
            }

            // Right: Cloud Storage & Workspaces Card (40% width)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 40
                radius: 18
                color: root.theme.surface
                border.color: root.theme.border_
                border.width: 1
                implicitHeight: cldCol.implicitHeight + 36

                ColumnLayout {
                    id: cldCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 14

                    Text {
                        text: "CLOUD & WORKSPACE DRIVES"
                        font.pixelSize: 11
                        font.weight: Font.ExtraBold
                        font.letterSpacing: 1.2
                        color: root.theme.textMuted
                    }

                    // Main Data Drive
                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: 10
                        color: d1Hov.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                        border.color: d1Hov.containsMouse ? "#0284C7" : root.theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text { text: "☁️"; font.pixelSize: 18 }
                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true
                                Text { text: "Google Drive (Main Data)"; font.pixelSize: 12; font.weight: Font.Bold; color: root.theme.textPrimary }
                                Text { text: "Persistent storage session"; font.pixelSize: 10; color: root.theme.textMuted }
                            }
                            Text { text: "Open →"; font.pixelSize: 11; font.weight: Font.Bold; color: "#0284C7" }
                        }

                        MouseArea {
                            id: d1Hov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.navigate("googleDriveMain")
                        }
                    }

                    // Thumbnail Reference Drive
                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: 10
                        color: d2Hov.containsMouse ? root.theme.surfaceElevated : root.theme.surface2
                        border.color: d2Hov.containsMouse ? "#0D9488" : root.theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text { text: "📂"; font.pixelSize: 18 }
                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true
                                Text { text: "Reference Thumbnail Drive"; font.pixelSize: 12; font.weight: Font.Bold; color: root.theme.textPrimary }
                                Text { text: "Client preview sync"; font.pixelSize: 10; color: root.theme.textMuted }
                            }
                            Text { text: "Open →"; font.pixelSize: 11; font.weight: Font.Bold; color: "#0D9488" }
                        }

                        MouseArea {
                            id: d2Hov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.navigate("googleDriveThumbs")
                        }
                    }
                }
            }
        }

        Item { height: 16 }
    }
}
