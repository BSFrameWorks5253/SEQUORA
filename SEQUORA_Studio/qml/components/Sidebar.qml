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

    property var toolsModel: [
        { key: "photoMatcher",       icon: "photo",   label: "Photo Matcher",       color: "#8B5CF6", bgSoft: "#F3EEFC" },
        { key: "videoTransfer",      icon: "video",   label: "Video Matcher",       color: "#10B981", bgSoft: "#ECFDF5" },
        { key: "pvSeparator",        icon: "box",     label: "PV Separator",        color: "#06B6D4", bgSoft: "#F0F9FF" },
        { key: "remainingCollector", icon: "layers",  label: "Remaining Shifter",   color: "#EC4899", bgSoft: "#FDF2F8" },
        { key: "excelMerger",        icon: "report",  label: "Report Merger",       color: "#F59E0B", bgSoft: "#FFFBEB" }
    ]

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

        // ── Brand Wordmark Header with Glowing Emblem ─────────────────────────
        Item {
            Layout.fillWidth: true
            height: 72

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Official SEQUORA App Mark with Glow
                Item {
                    width: 44
                    height: 44

                    Rectangle {
                        anchors.centerIn: parent
                        width: 48; height: 48; radius: 14
                        color: Qt.rgba(0.65, 0.35, 1.0, 0.25)
                        visible: root.theme.isDark

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.2; to: 0.55; duration: 1600; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.55; to: 0.2; duration: 1600; easing.type: Easing.InOutQuad }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: root.theme.isDark ? "#12121B" : "#FAF7F2"
                        border.color: root.theme.border_
                        border.width: 1
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 3
                            source: "../assets/icon.png"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            smooth: true
                        }
                    }
                }

                ColumnLayout {
                    spacing: 1
                    Layout.fillWidth: true

                    Text {
                        text: "SEQUORA"
                        font.pixelSize: 15
                        font.weight: Font.Black
                        font.letterSpacing: 2.2
                        color: root.theme.textPrimary
                    }
                    Text {
                        text: "STUDIO SUITE"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 1.4
                        color: root.theme.accent
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.theme.borderSubtle
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
                        { key: "overview", icon: "grid", label: "Overview", color: "#8B5CF6", bgSoft: "#F3EEFD" }
                    ]
                    delegate: navDelegate
                }

                // TOOLS
                Text {
                    text: "STUDIO TOOLS"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme.textMuted
                    font.letterSpacing: 1.2
                    leftPadding: 20
                    topPadding: 14
                    bottomPadding: 4
                }

                Repeater {
                    model: root.toolsModel
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
                        { key: "googleDriveMain",   icon: "cloud",  label: "Main Data Drive",   color: "#0284C7", bgSoft: "#F0F9FF" },
                        { key: "googleDriveThumbs", icon: "thumbs", label: "Reference Drive",   color: "#0D9488", bgSoft: "#F0FDFA" }
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
                        { key: "activity", icon: "activity", label: "Activity Log", color: "#8B5CF6", bgSoft: "#F5F3FF" }
                    ]
                    delegate: navDelegate
                }

                Item { height: 12 }
            }
        }

        // ── Settings Footer ───────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height: 54

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                radius: 8
                color: setHov.containsMouse ? root.theme.surface2 : "transparent"
                border.color: setHov.containsMouse ? root.theme.accent : "transparent"
                border.width: 1

                scale: setHov.pressed ? 0.98 : (setHov.containsMouse ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    StudioIcon {
                        name: "settings"
                        size: 16
                        color: setHov.containsMouse ? root.theme.accent : root.theme.textMuted
                        rotation: setHov.containsMouse ? 45 : 0
                        Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
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
                color: root.theme.borderSubtle
            }
        }
    }

    // ── Nav Item Delegate with Spring Glow Pill ───────────────────────────────
    Component {
        id: navDelegate

        Item {
            id: navItem
            Layout.fillWidth: true
            height: 40

            property bool isActive: root.activePage === modelData.key
            property bool isHovered: nHov.containsMouse

            Rectangle {
                id: pill
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                radius: 9

                color: navItem.isActive
                       ? (root.theme.isDark ? Qt.rgba(0.54, 0.36, 0.96, 0.20) : modelData.bgSoft)
                       : (navItem.isHovered ? root.theme.surface2 : "transparent")

                border.color: navItem.isActive
                              ? (root.theme.isDark ? modelData.color : Qt.rgba(0.54, 0.36, 0.96, 0.5))
                              : (navItem.isHovered ? root.theme.border_ : "transparent")
                border.width: 1

                scale: navItem.isHovered && !navItem.isActive ? 1.02 : 1.0

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                // Solid left color indicator bar on active with smooth slide in
                Rectangle {
                    visible: navItem.isActive
                    width: 3.5
                    height: 20
                    radius: 2
                    color: modelData.color
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    spacing: 11

                    // Crisp Vector Icon with spring scale
                    StudioIcon {
                        name: modelData.icon
                        size: 16
                        color: navItem.isActive
                               ? modelData.color
                               : (navItem.isHovered ? root.theme.textPrimary : root.theme.textSecondary)
                        scale: navItem.isHovered || navItem.isActive ? 1.15 : 1.0
                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
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

                    // Active Chevron
                    Text {
                        visible: navItem.isActive
                        text: "›"
                        font.pixelSize: 16
                        font.weight: Font.Black
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
