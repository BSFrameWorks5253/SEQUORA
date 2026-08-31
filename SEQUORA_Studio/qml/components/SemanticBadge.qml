// ============================================================
// qml/components/SemanticBadge.qml
// Studio Pro Semantic Badge (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme

    // Configuration Properties
    property string text: ""
    property string type: "default" // "camA" | "camB" | "matched" | "mismatch" | "unmatched" | "dryRun" | "live" | "success" | "warning" | "danger" | "info" | "default"
    property bool showDot: true
    property bool pulseDot: false
    property int fontSize: 10
    property bool isMonospace: true

    // Computed Theme Colors based on Semantic Type
    readonly property color badgeColor: {
        switch (root.type) {
            case "camA": return root.theme.camA || "#818CF8"
            case "camB": return root.theme.camB || "#F472B6"
            case "matched":
            case "success": return root.theme.success || "#34D399"
            case "mismatch":
            case "warning": return root.theme.warning || "#FBBF24"
            case "danger": return root.theme.danger || "#F87171"
            case "dryRun":
            case "info": return root.theme.info || "#38BDF8"
            case "live": return root.theme.accent || "#8064C9"
            case "unmatched":
            default: return root.theme.textMuted || "#71717A"
        }
    }

    readonly property color badgeBg: {
        switch (root.type) {
            case "camA": return root.theme.camASoft || Qt.rgba(0.5, 0.55, 0.97, 0.14)
            case "camB": return root.theme.camBSoft || Qt.rgba(0.96, 0.45, 0.71, 0.14)
            case "matched":
            case "success": return root.theme.successSoft || Qt.rgba(0.2, 0.83, 0.6, 0.12)
            case "mismatch":
            case "warning": return root.theme.warningSoft || Qt.rgba(0.98, 0.75, 0.14, 0.12)
            case "danger": return root.theme.dangerSoft || Qt.rgba(0.97, 0.44, 0.44, 0.12)
            case "dryRun":
            case "info": return root.theme.infoSoft || Qt.rgba(0.22, 0.74, 0.97, 0.12)
            case "live": return root.theme.accentSoft || Qt.rgba(0.5, 0.39, 0.79, 0.14)
            case "unmatched":
            default: return root.theme.isDark ? Qt.rgba(0.44, 0.44, 0.48, 0.12) : Qt.rgba(0.44, 0.44, 0.48, 0.08)
        }
    }

    implicitHeight: 22
    implicitWidth: contentRow.implicitWidth + 16
    radius: 11
    color: badgeBg
    border.color: Qt.rgba(badgeColor.r, badgeColor.g, badgeColor.b, root.theme.isDark ? 0.35 : 0.28)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5

        // Glowing Semantic Pip Indicator
        Rectangle {
            id: dotPip
            visible: root.showDot
            width: 6; height: 6
            radius: 3
            color: root.badgeColor

            // Subtle glow ring
            Rectangle {
                anchors.centerIn: parent
                width: 10; height: 10
                radius: 5
                color: "transparent"
                border.color: root.badgeColor
                border.width: 1
                opacity: root.pulseDot ? pulseAnim.glowOpacity : 0.4
            }

            SequentialAnimation {
                id: pulseAnim
                running: root.pulseDot && root.visible
                loops: Animation.Infinite
                property real glowOpacity: 0.3
                NumberAnimation { target: pulseAnim; property: "glowOpacity"; from: 0.2; to: 0.8; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { target: pulseAnim; property: "glowOpacity"; from: 0.8; to: 0.2; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        // Crisp Typography Label
        Text {
            id: labelText
            text: root.text.toUpperCase()
            font.pixelSize: root.fontSize
            font.family: root.isMonospace ? "Consolas, 'SF Mono', Monaco, monospace" : "Inter, -apple-system, sans-serif"
            font.weight: Font.Bold
            font.letterSpacing: 0.8
            color: root.badgeColor
            verticalAlignment: Text.AlignVCenter
        }
    }
}
