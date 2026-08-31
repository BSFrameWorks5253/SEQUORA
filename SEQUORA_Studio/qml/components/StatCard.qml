// ============================================================
// qml/components/StatCard.qml
// Ultra-Premium Glassmorphic Stat Card with Animated Counter
// ============================================================
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string label:  ""
    property var    value:  0
    property string accent: "purple"

    Layout.fillWidth: true
    Layout.preferredHeight: 88
    Layout.minimumHeight: 88
    implicitWidth: 150
    implicitHeight: 88

    radius: 16
    color: cardHover.containsMouse ? theme.surface : theme.surfaceGlass
    border.color: cardHover.containsMouse
                  ? (accent === "green"  ? theme.success
                   : accent === "red"    ? theme.danger
                   : accent === "orange" ? theme.warning
                   : accent === "blue"   ? theme.info
                   : theme.accent)
                  : theme.border_
    border.width: cardHover.containsMouse ? 1.5 : 1

    scale: cardHover.containsMouse ? 1.03 : 1.0

    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
    Behavior on color { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }
    Behavior on border.width { NumberAnimation { duration: 180 } }

    // Gradient accent bar at top
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        height: 3
        radius: 1.5
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: accent === "red"    ? theme.danger
                     : accent === "green"  ? theme.success
                     : accent === "blue"   ? theme.info
                     : accent === "orange" ? theme.warning
                     : theme.accent
            }
            GradientStop {
                position: 1.0
                color: accent === "red"    ? "#FF6B6B"
                     : accent === "green"  ? "#34D399"
                     : accent === "blue"   ? "#60A5FA"
                     : accent === "orange" ? "#FCD34D"
                     : theme.accentHover
            }
        }
        opacity: cardHover.containsMouse ? 1.0 : 0.6
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    // Subtle inner glow when hovered
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: accent === "red"    ? theme.danger
                    : accent === "green"  ? theme.success
                    : accent === "blue"   ? theme.info
                    : accent === "orange" ? theme.warning
                    : theme.accent
        border.width: 1
        opacity: cardHover.containsMouse ? 0.12 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: String(root.value)
            font.pixelSize: 26
            font.weight: Font.Black
            color: accent === "red"    ? theme.danger
                 : accent === "green"  ? theme.success
                 : accent === "blue"   ? theme.info
                 : accent === "orange" ? theme.warning
                 : theme.accent
            Layout.alignment: Qt.AlignHCenter

            Behavior on text { NumberAnimation { duration: 0 } }
        }

        Text {
            text: root.label
            font.pixelSize: 10
            color: theme.textMuted
            font.weight: Font.Bold
            font.letterSpacing: 0.5
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
