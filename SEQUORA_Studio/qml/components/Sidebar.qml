// ============================================================
// qml/components/Sidebar.qml
// Professional Desktop Sidebar Navigation (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string activePage: "overview"
    signal navigate(string pageKey)
    signal openSettings()

    width: 236
    Layout.fillHeight: true
    color: root.theme.sidebar

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: root.theme.border_
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Brand Wordmark Header ─────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height: 68

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Official SEQUORA App Mark
                Rectangle {
                    width: 38
                    height: 38
                    radius: 10
                    color: "transparent"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "../assets/icon.png"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        smooth: true
                        sourceSize: Qt.size(128, 128)
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Text {
                        text: "SEQUORA"
                        font.pixelSize: 15
                        font.weight: Font.Black
                        font.letterSpacing: 2.0
                        color: root.theme.textPrimary
                    }
                    Text {
                        text: "CREATIVE SUITE"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 1.2
                        color: root.theme.accent
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.border_
            }
        }

        // ── Scrollable Nav Menu ───────────────────────────────────────────────
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 2

                // WORKSPACE
                Text {
                    text: "WORKSPACE"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme.textMuted
                    font.letterSpacing: 1.2
                    leftPadding: 20
                    topPadding: 14
                    bottomPadding: 4
                }

                Repeater {
                    model: [
                        { key: "overview", icon: "◻", label: "Overview", color: "#6366F1", bgSoft: "#EEF2FF" }
                    ]
                    delegate: navDelegate
                }

                // TOOLS
                Text {
                    text: "TOOLS"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme.textMuted
                    font.letterSpacing: 1.2
                    leftPadding: 20
                    topPadding: 14
                    bottomPadding: 4
                }

                Repeater {
                    model: [
                        { key: "photoMatcher",       icon: "📸", label: "Photo Matcher",       color: "#7C5CBF", bgSoft: "#F3EEFC" },
                        { key: "videoTransfer",      icon: "🎬", label: "Video Matcher",       color: "#059669", bgSoft: "#ECFDF5" },
                        { key: "pvSeparator",        icon: "📦", label: "PV Separator",        color: "#D97706", bgSoft: "#FFFBEB" },
                        { key: "remainingCollector", icon: "📦", label: "Remaining Shifter",   color: "#DB2777", bgSoft: "#FDF2F8" },
                        { key: "excelMerger",        icon: "📑", label: "Report Merger",       color: "#10B981", bgSoft: "#ECFDF5" }
                    ]
                    delegate: navDelegate
                }

                // CLOUD
                Text {
                    text: "CLOUD WORKSPACES"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme.textMuted
                    font.letterSpacing: 1.2
                    leftPadding: 20
                    topPadding: 14
                    bottomPadding: 4
                }

                Repeater {
                    model: [
                        { key: "googleDriveMain",   icon: "☁️", label: "Main Data Drive",   color: "#0284C7", bgSoft: "#F0F9FF" },
                        { key: "googleDriveThumbs", icon: "📂", label: "Reference Drive",   color: "#0D9488", bgSoft: "#F0FDFA" }
                    ]
                    delegate: navDelegate
                }

                // SYSTEM
                Text {
                    text: "SYSTEM & AUDIT"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme.textMuted
                    font.letterSpacing: 1.2
                    leftPadding: 20
                    topPadding: 14
                    bottomPadding: 4
                }

                Repeater {
                    model: [
                        { key: "activity", icon: "⏱", label: "Activity Log", color: "#8B5CF6", bgSoft: "#F5F3FF" }
                    ]
                    delegate: navDelegate
                }

                Item { height: 12 }
            }
        }

        // ── Settings Footer ───────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height: 52

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                radius: 6
                color: setHov.containsMouse ? root.theme.surface2 : "transparent"
                border.color: setHov.containsMouse ? root.theme.border_ : "transparent"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: "⚙"
                        font.pixelSize: 15
                        color: setHov.containsMouse ? root.theme.accent : root.theme.textMuted
                        scale: setHov.containsMouse ? 1.15 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                    }

                    Text {
                        text: "Settings & Preferences"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: setHov.containsMouse ? root.theme.accent : root.theme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    id: setHov
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.openSettings()
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.border_
            }
        }
    }

    // ── Nav Item Delegate ─────────────────────────────────────────────────────
    Component {
        id: navDelegate

        Item {
            id: navItem
            Layout.fillWidth: true
            height: 38

            property bool isActive: root.activePage === modelData.key
            property bool isHovered: nHov.containsMouse

            Rectangle {
                id: pill
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                radius: 8

                color: navItem.isActive
                       ? (root.theme.isDark ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.18) : modelData.bgSoft)
                       : (navItem.isHovered ? root.theme.surface2 : "transparent")

                border.color: navItem.isActive
                              ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, root.theme.isDark ? 0.45 : 0.6)
                              : (navItem.isHovered ? root.theme.border_ : "transparent")
                border.width: 1

                scale: navItem.isHovered && !navItem.isActive ? 1.01 : 1.0

                Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                // Solid left color indicator bar on active with smooth slide in
                Rectangle {
                    visible: navItem.isActive
                    width: 3
                    height: 18
                    radius: 1.5
                    color: modelData.color
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 12
                    spacing: 10

                    // Icon with subtle spring scale
                    Text {
                        text: modelData.icon
                        font.pixelSize: 14
                        scale: navItem.isHovered || navItem.isActive ? 1.15 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 12
                        font.weight: navItem.isActive ? Font.Bold : Font.DemiBold
                        color: navItem.isActive
                               ? (root.theme.isDark ? "#FFFFFF" : modelData.color)
                               : (navItem.isHovered ? root.theme.textPrimary : root.theme.textSecondary)
                        Layout.fillWidth: true
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    // Chevron on active
                    Text {
                        visible: navItem.isActive
                        text: "›"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: modelData.color
                    }
                }

                MouseArea {
                    id: nHov
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.navigate(modelData.key)
                }
            }
        }
    }
}
