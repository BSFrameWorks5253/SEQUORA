// ============================================================
// qml/components/CustomScrollBar.qml
// Ultra-Sleek Pill ScrollBar with Expand-on-Hover + Fade
// ============================================================
import QtQuick
import QtQuick.Templates 2.15 as T

T.ScrollBar {
    id: control
    required property var theme

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 2
    visible: control.policy === T.ScrollBar.AlwaysOn ||
             (control.policy === T.ScrollBar.AsNeeded && control.size < 1.0)
    hoverEnabled: true

    // Expand on hover/active
    property real targetWidth: (control.active || control.hovered || control.pressed) ? 7 : 4
    width: targetWidth
    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    contentItem: Rectangle {
        implicitWidth: 6
        implicitHeight: 60
        radius: width / 2

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: control.pressed
                       ? control.theme.accentHover
                       : (control.hovered ? control.theme.accent
                          : (control.theme.name === "dark" ? "#5E5880" : "#C0B4A6"))
            }
            GradientStop {
                position: 1.0
                color: control.pressed
                       ? control.theme.accent
                       : (control.hovered ? control.theme.accentHover
                          : (control.theme.name === "dark" ? "#4A4568" : "#ADA094"))
            }
        }

        opacity: (control.active || control.hovered || control.pressed) ? 0.9 : 0.38

        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // Subtle sheen when active
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.4
            radius: parent.radius
            color: "white"
            opacity: (control.hovered || control.pressed) ? 0.15 : 0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }
    }

    background: Item {
        implicitWidth: 0
        implicitHeight: 0
    }
}
