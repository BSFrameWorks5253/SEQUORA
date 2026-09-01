// ============================================================
// qml/components/StatCard.qml
// Ultra-Premium Glassmorphic Stat Card with Spring Hover & Ambient Glow
// ============================================================
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    property string label:  ""
    property var    value:  0
    property string accent: "purple"

    Layout.fillWidth: true
    Layout.preferredHeight: 90
    Layout.minimumHeight: 90
    implicitWidth: 150
    implicitHeight: 90

    readonly property color accentCol: {
        switch (root.accent) {
            case "green":   return root.theme ? root.theme.success : "#10B981"
            case "red":     return root.theme ? root.theme.danger : "#F43F5E"
            case "orange":
            case "amber":   return root.theme ? root.theme.warning : "#F59E0B"
            case "blue":
            case "cyan":    return root.theme ? root.theme.cyan : "#06B6D4"
            case "magenta": return root.theme ? root.theme.camB : "#EC4899"
            default:        return root.theme ? root.theme.accent : "#8B5CF6"
        }
    }

    // ── Outer Ambient Glow Aura ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: cardBody
        anchors.margins: -4
        radius: 20
        color: root.accentCol
        opacity: cardHover.containsMouse ? 0.25 : 0.0
        z: 0

        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    // ── Card Main Body ────────────────────────────────────────────────────────
    Rectangle {
        id: cardBody
        anchors.fill: parent
        radius: 16
        z: 1
        color: cardHover.containsMouse ? root.theme.surfaceElevated : root.theme.surfaceGlass
        border.color: cardHover.containsMouse ? root.accentCol : root.theme.border_
        border.width: cardHover.containsMouse ? 1.5 : 1

        scale: cardHover.containsMouse ? 1.03 : 1.0
        y: cardHover.containsMouse ? -3 : 0

        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
        Behavior on color { ColorAnimation { duration: 180 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }
        Behavior on border.width { NumberAnimation { duration: 180 } }

        // Gradient accent bar at top
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            height: 3
            radius: 1.5
            color: root.accentCol
            opacity: cardHover.containsMouse ? 1.0 : 0.7

            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: String(root.value)
                font.pixelSize: 26
                font.weight: Font.Black
                font.letterSpacing: -0.5
                color: root.accentCol
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: root.label
                font.pixelSize: 10
                color: root.theme.textMuted
                font.weight: Font.Bold
                font.letterSpacing: 0.6
                Layout.alignment: Qt.AlignHCenter
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: cardHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
