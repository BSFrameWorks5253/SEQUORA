// ============================================================
// qml/components/StudioButton.qml
// Ultra-High-End Animated Button Component (Apple Pro / Linear standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string text: ""
    property string iconSource: ""
    property string iconText: ""
    property string variant: "primary"   // "primary", "cyan", "success", "warning", "danger", "glass", "secondary", "ghost", "magenta"
    property string btnSize: "md"        // "sm" (30px), "md" (38px), "lg" (46px)
    property bool   loading: false
    property bool   glow: true
    property int    customRadius: -1
    property real   customWidth: -1
    property real   customHeight: -1
    property var    theme: null

    signal clicked()

    // ── Dimensions ────────────────────────────────────────────────────────────
    readonly property int computedHeight: {
        if (root.customHeight > 0) return root.customHeight
        if (root.btnSize === "sm") return 30
        if (root.btnSize === "lg") return 46
        return 38 // "md"
    }

    readonly property int computedRadius: {
        if (root.customRadius >= 0) return root.customRadius
        if (root.btnSize === "sm") return 7
        if (root.btnSize === "lg") return 12
        return 9
    }

    readonly property int fontSize: {
        if (root.btnSize === "sm") return 11
        if (root.btnSize === "lg") return 14
        return 12
    }

    readonly property int horizPadding: {
        if (root.btnSize === "sm") return 12
        if (root.btnSize === "lg") return 22
        return 16
    }

    implicitHeight: computedHeight
    implicitWidth: root.customWidth > 0 ? root.customWidth : (contentRow.implicitWidth + (horizPadding * 2))

    // ── Color Theme Matrix ────────────────────────────────────────────────────
    readonly property color gradStart: {
        if (!root.enabled) return root.theme ? (root.theme.isDark ? "#2A2A38" : "#E2E8F0") : "#333333"
        switch (root.variant) {
            case "primary":   return root.theme ? root.theme.accent : "#8B5CF6"
            case "cyan":      return root.theme ? root.theme.info : "#06B6D4"
            case "success":   return root.theme ? root.theme.success : "#10B981"
            case "warning":   return root.theme ? root.theme.warning : "#F59E0B"
            case "danger":    return root.theme ? root.theme.danger : "#F43F5E"
            case "magenta":   return root.theme ? root.theme.camB : "#EC4899"
            case "glass":
            case "secondary": return root.theme ? root.theme.surfaceElevated : "#1E1E2A"
            case "ghost":     return "transparent"
            default:          return root.theme ? root.theme.accent : "#8B5CF6"
        }
    }

    readonly property color gradEnd: {
        if (!root.enabled) return root.theme ? (root.theme.isDark ? "#20202C" : "#CBD5E1") : "#222222"
        switch (root.variant) {
            case "primary":   return root.theme ? root.theme.accentHover : "#6D28D9"
            case "cyan":      return "#0284C7"
            case "success":   return "#059669"
            case "warning":   return "#D97706"
            case "danger":    return "#DC2626"
            case "magenta":   return "#DB2777"
            case "glass":
            case "secondary": return root.theme ? root.theme.surface2 : "#262638"
            case "ghost":     return "transparent"
            default:          return root.theme ? root.theme.accentHover : "#6D28D9"
        }
    }

    readonly property color textColor: {
        if (!root.enabled) return root.theme ? root.theme.textMuted : "#888888"
        if (root.variant === "glass" || root.variant === "secondary") return root.theme ? root.theme.textPrimary : "#FFFFFF"
        if (root.variant === "ghost") return mouseArea.containsMouse ? (root.theme ? root.theme.accent : "#8B5CF6") : (root.theme ? root.theme.textPrimary : "#FFFFFF")
        return "#FFFFFF"
    }

    readonly property color borderColor: {
        if (!root.enabled) return "transparent"
        if (root.variant === "glass" || root.variant === "secondary") {
            return mouseArea.containsMouse
                ? (root.theme ? root.theme.accent : "#8B5CF6")
                : (root.theme ? root.theme.border_ : "#333344")
        }
        if (root.variant === "ghost") {
            return mouseArea.containsMouse ? (root.theme ? root.theme.borderSubtle : "#333344") : "transparent"
        }
        return mouseArea.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.4) : Qt.rgba(1.0, 1.0, 1.0, 0.15)
    }

    readonly property color glowColor: {
        switch (root.variant) {
            case "primary": return Qt.rgba(0.54, 0.36, 0.96, 0.35)
            case "cyan":    return Qt.rgba(0.02, 0.71, 0.83, 0.35)
            case "success": return Qt.rgba(0.06, 0.72, 0.50, 0.35)
            case "warning": return Qt.rgba(0.96, 0.62, 0.04, 0.35)
            case "danger":  return Qt.rgba(0.95, 0.25, 0.37, 0.35)
            case "magenta": return Qt.rgba(0.92, 0.28, 0.60, 0.35)
            default:        return Qt.rgba(0.54, 0.36, 0.96, 0.25)
        }
    }

    // ── Outer Glow Aura ───────────────────────────────────────────────────────
    Rectangle {
        id: glowAura
        anchors.fill: buttonBody
        anchors.margins: -4
        radius: root.computedRadius + 4
        color: root.glowColor
        opacity: (root.glow && root.enabled && mouseArea.containsMouse && root.variant !== "ghost" && root.variant !== "glass" && root.variant !== "secondary") ? 1.0 : 0.0
        z: 0

        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    // ── Main Button Body with Spring Transform ────────────────────────────────
    Rectangle {
        id: buttonBody
        anchors.fill: parent
        radius: root.computedRadius
        z: 1
        clip: true

        scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.03 : 1.0)
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: mouseArea.pressed ? 90 : 220
                easing.type: mouseArea.pressed ? Easing.OutQuad : Easing.OutBack
                easing.overshoot: 1.6
            }
        }

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: root.gradStart }
            GradientStop { position: 1.0; color: root.gradEnd }
        }

        border.color: root.borderColor
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 180 } }

        // Top Specular Highlight Line
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: root.computedRadius
            color: Qt.rgba(1.0, 1.0, 1.0, root.theme && root.theme.isDark ? 0.20 : 0.40)
            visible: root.variant !== "ghost"
        }

        // ── Diagonal Shine Light Beam Sweep ───────────────────────────────────
        Rectangle {
            id: shineBeam
            width: parent.width * 0.75
            height: parent.height * 2.5
            y: -parent.height * 0.75
            x: -width * 1.5
            rotation: 25
            visible: root.enabled && root.variant !== "ghost"

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(1.0, 1.0, 1.0, 0.22) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            SequentialAnimation {
                id: shineAnim
                NumberAnimation {
                    target: shineBeam
                    property: "x"
                    from: -shineBeam.width * 1.5
                    to: buttonBody.width * 1.5
                    duration: 650
                    easing.type: Easing.InOutQuad
                }
                PropertyAction { target: shineBeam; property: "x"; value: -shineBeam.width * 1.5 }
            }
        }

        // ── Content Row (Icon + Text + Spinner) ───────────────────────────────
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8

            // Loading Spinner
            Rectangle {
                id: spinner
                visible: root.loading
                width: 14; height: 14; radius: 7
                color: "transparent"
                border.color: root.textColor
                border.width: 2

                RotationAnimation on rotation {
                    running: root.loading
                    loops: Animation.Infinite
                    from: 0; to: 360
                    duration: 800
                }
            }

            // Emoji / Text Icon with Micro-Animation
            Text {
                id: iconTxt
                visible: !root.loading && root.iconText !== ""
                text: root.iconText
                font.pixelSize: root.fontSize + 2
                scale: mouseArea.containsMouse ? 1.15 : 1.0
                rotation: mouseArea.containsMouse ? -6 : 0

                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            }

            // Image Icon
            Image {
                id: imgIcon
                visible: !root.loading && root.iconSource !== ""
                source: root.iconSource
                width: root.fontSize + 2
                height: root.fontSize + 2
                fillMode: Image.PreserveAspectFit
                smooth: true
                scale: mouseArea.containsMouse ? 1.12 : 1.0

                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            }

            // Label Text
            Text {
                id: labelText
                text: root.text
                font.pixelSize: root.fontSize
                font.weight: Font.Bold
                font.letterSpacing: 0.4
                color: root.textColor
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: 160 } }
            }
        }

        // ── Mouse Area ────────────────────────────────────────────────────────
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: root.enabled && !root.loading
            cursorShape: (root.enabled && !root.loading) ? Qt.PointingHandCursor : Qt.ArrowCursor

            onEntered: {
                if (root.enabled && !root.loading && !shineAnim.running) {
                    shineAnim.restart()
                }
            }

            onClicked: {
                if (root.enabled && !root.loading) {
                    root.clicked()
                }
            }
        }
    }
}
