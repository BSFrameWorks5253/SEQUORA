// ============================================================
// qml/components/SplashScreen.qml
// Simple, Sweet & Ultra-Premium Startup Reveal (Apple Pro standard)
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    property bool isFinished: false
    signal finished()

    anchors.fill: parent
    z: 99999
    visible: opacity > 0

    // Ultra-Smooth Exit Transition
    opacity: 1.0
    scale: 1.0

    Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    function dismiss() {
        if (root.isFinished) return
        root.isFinished = true
        root.opacity = 0.0
        root.scale = 1.04
        dismissTimer.start()
    }

    Timer {
        id: dismissTimer
        interval: 340
        repeat: false
        onTriggered: {
            root.visible = false
            root.finished()
        }
    }

    // Auto-dismiss after a sweet, snappy reveal (950ms total)
    Timer {
        interval: 950
        running: true
        repeat: false
        onTriggered: root.dismiss()
    }

    // ── Deep Velvet Obsidian Canvas ───────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#08080C"

        // Ambient Soft Ultraviolet Glow Halo
        Rectangle {
            anchors.centerIn: parent
            width: 380; height: 380; radius: 190
            color: "#8B5CF6"
            opacity: 0.18

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.12; to: 0.24; duration: 1600; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.24; to: 0.12; duration: 1600; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 0.95; to: 1.08; duration: 2000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.08; to: 0.95; duration: 2000; easing.type: Easing.InOutSine }
            }
        }

        // ── Centered Minimalist Brand Reveal ──────────────────────────────────
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16
            scale: 0.92
            opacity: 0.0

            Component.onCompleted: entranceAnim.start()

            ParallelAnimation {
                id: entranceAnim
                NumberAnimation {
                    target: parent
                    property: "scale"
                    from: 0.92; to: 1.0
                    duration: 480
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
                NumberAnimation {
                    target: parent
                    property: "opacity"
                    from: 0.0; to: 1.0
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }

            // 3D Metallic SEQUORA Logo Emblem
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 140
                height: 140

                Image {
                    anchors.fill: parent
                    source: "../assets/icon.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                }
            }

            // Minimalist Brand Typography
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    text: "SEQUORA"
                    font.pixelSize: 20
                    font.weight: Font.Black
                    font.letterSpacing: 6.0
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "CREATIVE STUDIO"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 3.0
                    color: "#A78BFA"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            Item { height: 4 }

            // Whisper-Thin Glowing Shimmer Accent Line
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 90
                height: 2
                radius: 1
                color: "#161622"
                clip: true

                Rectangle {
                    id: shimmerBar
                    width: 30
                    height: 2
                    radius: 1
                    x: -30

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: "#C084FC" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        NumberAnimation { from: -30; to: 90; duration: 900; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }
    }

    // Instant Skip Handlers
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismiss()
    }

    Shortcut { sequence: "Escape"; onActivated: root.dismiss() }
    Shortcut { sequence: "Space"; onActivated: root.dismiss() }
    Shortcut { sequence: "Return"; onActivated: root.dismiss() }
}
