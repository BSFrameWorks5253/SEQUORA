// ============================================================
// qml/components/SkeletonLoader.qml
// Studio Shimmering Skeleton Loader for Asynchronous Operations
// ============================================================
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme

    property int rowCount: 4
    property int cardHeight: 52
    property int rowSpacing: 10
    property string mode: "rows" // "rows" | "cards" | "single"

    implicitWidth: parent ? parent.width : 400
    implicitHeight: mode === "single" ? cardHeight : (rowCount * cardHeight + (rowCount - 1) * rowSpacing)

    ColumnLayout {
        anchors.fill: parent
        spacing: root.rowSpacing

        Repeater {
            model: root.mode === "single" ? 1 : root.rowCount

            Rectangle {
                id: skeletonCard
                Layout.fillWidth: true
                Layout.preferredHeight: root.cardHeight
                radius: 8
                color: root.theme.isDark ? "#17171A" : "#ECEEF2"
                border.color: root.theme.borderSubtle
                border.width: 1
                clip: true

                // Animated Shimmer Gradient
                Rectangle {
                    id: shimmer
                    width: skeletonCard.width * 0.45
                    height: skeletonCard.height
                    anchors.verticalCenter: parent.verticalCenter
                    x: -width

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop {
                            position: 0.5
                            color: root.theme.isDark ? Qt.rgba(1.0, 1.0, 1.0, 0.06) : Qt.rgba(1.0, 1.0, 1.0, 0.45)
                        }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    NumberAnimation {
                        target: shimmer
                        property: "x"
                        from: -shimmer.width
                        to: skeletonCard.width + shimmer.width
                        duration: 1400
                        loops: Animation.Infinite
                        running: root.visible
                        easing.type: Easing.InOutQuad
                    }
                }

                // Inner Mock Elements (Avatar/icon + 2 text lines)
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 14

                    // Mock Icon/Thumbnail
                    Rectangle {
                        width: 32; height: 32; radius: 6
                        color: root.theme.isDark ? "#222227" : "#DEE2E6"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        // Mock Line 1
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.maximumWidth: index % 2 === 0 ? 320 : 220
                            height: 10; radius: 4
                            color: root.theme.isDark ? "#25252B" : "#D6D9E0"
                        }

                        // Mock Line 2
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.maximumWidth: index % 2 === 0 ? 180 : 120
                            height: 8; radius: 4
                            color: root.theme.isDark ? "#1E1E23" : "#E2E5EB"
                        }
                    }

                    // Mock Status Badge
                    Rectangle {
                        width: 72; height: 18; radius: 9
                        color: root.theme.isDark ? "#202026" : "#E2E5EB"
                    }
                }
            }
        }
    }
}
