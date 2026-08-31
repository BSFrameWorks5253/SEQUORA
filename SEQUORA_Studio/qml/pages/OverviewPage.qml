// ============================================================
// qml/pages/OverviewPage.qml
// SYNCHRO Studio — High-Performance Creative Production Workspace
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    required property var theme
    signal navigate(string pageKey)

    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        width: Math.min(1160, parent.width - 48)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 22

        Item { height: 4 }

        // ── 1. Hero Production Hub Banner ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 124
            radius: 10
            color: root.theme.surface
            border.color: root.theme.border_
            border.width: 1

            // Subtle top highlight
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                radius: 1.5
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#7C5CBF" }
                    GradientStop { position: 0.35; color: "#059669" }
                    GradientStop { position: 0.70; color: "#D97706" }
                    GradientStop { position: 1.0; color: "#DB2777" }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            width: 7; height: 7; radius: 3.5
                            color: root.theme.success
                        }
                        Text {
                            text: "SEQUORA PRODUCTION WORKSPACE"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            font.letterSpacing: 1.2
                            color: root.theme.accent
                        }
                    }

                    Text {
                        text: "Multi-Camera Studio Ingest & Delivery"
                        font.pixelSize: 20
                        font.weight: Font.ExtraBold
                        color: root.theme.textPrimary
                    }

                    Text {
                        text: "Automated sequence pairing, status synchronization, thumbnail extraction & Google Drive cloud packaging."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                    }
                }

                // Quick telemetry tags
                ColumnLayout {
                    spacing: 6
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    Rectangle {
                        height: 24
                        width: t1Row.implicitWidth + 14
                        radius: 12
                        color: root.theme.surface2
                        border.color: root.theme.borderSubtle
                        border.width: 1
                        RowLayout {
                            id: t1Row; anchors.centerIn: parent; spacing: 5
                            Text { text: "✓"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.success }
                            Text { text: "MQ / MF / H Events Auto-Bypassed"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textSecondary }
                        }
                    }

                    Rectangle {
                        height: 24
                        width: t2Row.implicitWidth + 14
                        radius: 12
                        color: root.theme.surface2
                        border.color: root.theme.borderSubtle
                        border.width: 1
                        RowLayout {
                            id: t2Row; anchors.centerIn: parent; spacing: 5
                            Text { text: "⚡"; font.pixelSize: 10; color: root.theme.accent }
                            Text { text: "Persistent Cloud Session Active"; font.pixelSize: 10; font.weight: Font.Bold; color: root.theme.textSecondary }
                        }
                    }
                }
            }
        }

        // ── 2. 4 Studio Production Modules ────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: parent.width > 780 ? 2 : 1
            columnSpacing: 16
            rowSpacing: 16

            // Module 1: Photo Matcher (Royal Purple / Violet)
            Rectangle {
                Layout.fillWidth: true
                height: 168
                radius: 10
                color: root.theme.surface
                border.color: c1Hov.containsMouse ? "#7C5CBF" : root.theme.border_
                border.width: c1Hov.containsMouse ? 1.5 : 1
                scale: c1Hov.pressed ? 0.98 : (c1Hov.containsMouse ? 1.012 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 3; radius: 1.5; color: "#7C5CBF"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 10
                        Rectangle {
                            width: 32; height: 32; radius: 6
                            color: "#F3EEFC"
                            Text { anchors.centerIn: parent; text: "📸"; font.pixelSize: 15 }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "PHOTO REMAINING MATCHER"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                font.letterSpacing: 1.0
                                color: "#7C5CBF"
                            }
                            Text {
                                text: "Safety-validated _U / _R synchronization"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.theme.textMuted
                            }
                        }
                    }

                    Text {
                        text: "Match remaining photos against event subfolders with full extension preservation and instant report generation."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            height: 20; width: f1.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: f1; anchors.centerIn: parent; text: "CR3 / ARW / JPG"; font.pixelSize: 10; font.family: "Consolas, monospace"; color: root.theme.textMuted }
                        }
                        Rectangle {
                            height: 20; width: f2.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: f2; anchors.centerIn: parent; text: "Non-destructive"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Open Tool →"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#7C5CBF"
                        }
                    }
                }

                MouseArea {
                    id: c1Hov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigate("photoMatcher")
                }
            }

            // Module 2: Video Matcher (Emerald Green / Teal)
            Rectangle {
                Layout.fillWidth: true
                height: 168
                radius: 10
                color: root.theme.surface
                border.color: c2Hov.containsMouse ? "#059669" : root.theme.border_
                border.width: c2Hov.containsMouse ? 1.5 : 1
                scale: c2Hov.pressed ? 0.98 : (c2Hov.containsMouse ? 1.012 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 3; radius: 1.5; color: "#059669"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 10
                        Rectangle {
                            width: 32; height: 32; radius: 6
                            color: "#ECFDF5"
                            Text { anchors.centerIn: parent; text: "🎬"; font.pixelSize: 15 }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "VIDEO SEQUENCE MATCHER"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                font.letterSpacing: 1.0
                                color: "#059669"
                            }
                            Text {
                                text: "Smart date sequence & event pairing"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.theme.textMuted
                            }
                        }
                    }

                    Text {
                        text: "Pair multi-camera video clips with photo subfolders. Automatically bypasses non-video events (MQ, MF, H)."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            height: 20; width: v1.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: v1; anchors.centerIn: parent; text: "Auto-Ignore MQ/MF/H"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Rectangle {
                            height: 20; width: v2.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: v2; anchors.centerIn: parent; text: "Copy / Move Modes"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Open Tool →"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#059669"
                        }
                    }
                }

                MouseArea {
                    id: c2Hov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigate("videoTransfer")
                }
            }

            // Module 3: Thumbnail Separator (Warm Amber / Gold)
            Rectangle {
                Layout.fillWidth: true
                height: 168
                radius: 10
                color: root.theme.surface
                border.color: c3Hov.containsMouse ? "#D97706" : root.theme.border_
                border.width: c3Hov.containsMouse ? 1.5 : 1
                scale: c3Hov.pressed ? 0.98 : (c3Hov.containsMouse ? 1.012 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 3; radius: 1.5; color: "#D97706"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 10
                        Rectangle {
                            width: 32; height: 32; radius: 6
                            color: "#FFFBEB"
                            Text { anchors.centerIn: parent; text: "🖼"; font.pixelSize: 15 }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "THUMBNAIL SEPARATOR"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                font.letterSpacing: 1.0
                                color: "#D97706"
                            }
                            Text {
                                text: "_P & _V Preview Package Extractor"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.theme.textMuted
                            }
                        }
                    }

                    Text {
                        text: "Extract and isolate all client-facing _P and _V preview thumbnails into unified packages with 1-click rollback."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            height: 20; width: t1.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: t1; anchors.centerIn: parent; text: "Photo & Video Thumbs"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Rectangle {
                            height: 20; width: t2.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: t2; anchors.centerIn: parent; text: "Instant Undo"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Open Tool →"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#D97706"
                        }
                    }
                }

                MouseArea {
                    id: c3Hov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigate("thumbnailSeparator")
                }
            }

            // Module 4: Remaining Shifter (Studio Rose / Coral)
            Rectangle {
                Layout.fillWidth: true
                height: 168
                radius: 10
                color: root.theme.surface
                border.color: c4Hov.containsMouse ? "#DB2777" : root.theme.border_
                border.width: c4Hov.containsMouse ? 1.5 : 1
                scale: c4Hov.pressed ? 0.98 : (c4Hov.containsMouse ? 1.012 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: 3; radius: 1.5; color: "#DB2777"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 10
                        Rectangle {
                            width: 32; height: 32; radius: 6
                            color: "#FDF2F8"
                            Text { anchors.centerIn: parent; text: "📦"; font.pixelSize: 15 }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "REMAINING PHOTOS SHIFTER"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                font.letterSpacing: 1.0
                                color: "#DB2777"
                            }
                            Text {
                                text: "Date Folder Tree Consolidator"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.theme.textMuted
                            }
                        }
                    }

                    Text {
                        text: "Consolidate scattered Remaining Photos folders across multiple camera cards into target date folder trees."
                        font.pixelSize: 12
                        color: root.theme.textSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            height: 20; width: s1.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: s1; anchors.centerIn: parent; text: "Batch Consolidate"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Rectangle {
                            height: 20; width: s2.implicitWidth + 10; radius: 4
                            color: root.theme.surface2
                            Text { id: s2; anchors.centerIn: parent; text: "Date Mapping"; font.pixelSize: 10; font.weight: Font.DemiBold; color: root.theme.textMuted }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Open Tool →"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#DB2777"
                        }
                    }
                }

                MouseArea {
                    id: c4Hov; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.navigate("remainingCollector")
                }
            }
        }

        // ── 3. Live Activity Audit Feed ───────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            RowLayout {
                spacing: 8
                Text {
                    text: "RECENT ACTIVITY LOG"
                    font.pixelSize: 11
                    font.weight: Font.ExtraBold
                    font.letterSpacing: 1.2
                    color: root.theme.textMuted
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "View Full History →"
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

            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color: root.theme.surface
                border.color: root.theme.border_
                border.width: 1
                implicitHeight: actCol.implicitHeight

                ColumnLayout {
                    id: actCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    // Clean Empty State
                    Item {
                        visible: !(typeof activityEngine !== "undefined" && activityEngine && activityEngine.activities && activityEngine.activities.length > 0)
                        Layout.fillWidth: true
                        height: 90

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "No recent activity recorded yet"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.theme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Select any tool from the workspace above to start batch scanning and syncing files."
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
                            color: actHov.containsMouse ? root.theme.surface2 : "transparent"

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
                                spacing: 14

                                Text {
                                    text: modelData.time || ""
                                    font.pixelSize: 11
                                    font.family: "Consolas, monospace"
                                    color: root.theme.textMuted
                                    Layout.preferredWidth: 70
                                }

                                Rectangle {
                                    height: 22
                                    width: toolBadgeTxt.implicitWidth + 12
                                    radius: 4
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
        }

        Item { height: 20 }
    }
}
