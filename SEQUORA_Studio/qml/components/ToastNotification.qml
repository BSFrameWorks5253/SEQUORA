// ============================================================
// qml/components/ToastNotification.qml
// Premium Glassmorphic Toast with Slide-Up + Progress Strip
// ============================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.bottom: parent ? parent.bottom : undefined
    anchors.right:  parent ? parent.right  : undefined
    anchors.bottomMargin: 28
    anchors.rightMargin: 28
    width: 340
    height: toastStack.implicitHeight
    z: 9999

    required property var theme

    function show(msg, type) {
        var palette = {
            "success": { bg: "#10B981", soft: root.theme.name === "dark" ? "#0D2A1A" : "#E6FBF3", icon: "✓", border: "#059669" },
            "danger":  { bg: "#EF4444", soft: root.theme.name === "dark" ? "#2A0D0D" : "#FEE8E8", icon: "✕", border: "#DC2626" },
            "warning": { bg: "#F59E0B", soft: root.theme.name === "dark" ? "#2A1D08" : "#FEF8E7", icon: "⚠", border: "#D97706" },
            "info":    { bg: "#3B82F6", soft: root.theme.name === "dark" ? "#0A1830" : "#EFF6FF", icon: "i", border: "#2563EB" }
        }
        var p = palette[type] || palette["info"]
        toastModel.append({
            message: msg,
            accent:  p.bg,
            soft:    p.soft,
            icon:    p.icon,
            border_: p.border
        })
    }

    ListModel {
        id: toastModel
    }

    Column {
        id: toastStack
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        spacing: 10

        Repeater {
            model: toastModel

            delegate: Item {
                id: toastItem
                width: 330
                height: toastInner.height
                clip: false

                property real lifeProgress: 1.0

                // Entry animation — slide up + fade
                NumberAnimation on opacity {
                    from: 0; to: 1
                    duration: 320
                    running: true
                    easing.type: Easing.OutCubic
                }
                NumberAnimation on y {
                    from: 20; to: 0
                    duration: 320
                    running: true
                    easing.type: Easing.OutBack
                }

                // Auto-dismiss timer
                Timer {
                    interval: 4500
                    running: true
                    repeat: false
                    onTriggered: {
                        exitAnim.start()
                        removeTimer.start()
                    }
                }
                SequentialAnimation {
                    id: exitAnim
                    ParallelAnimation {
                        NumberAnimation { target: toastItem; property: "opacity"; to: 0; duration: 280; easing.type: Easing.InCubic }
                        NumberAnimation { target: toastItem; property: "y"; to: 10; duration: 280; easing.type: Easing.InCubic }
                    }
                }
                Timer {
                    id: removeTimer
                    interval: 320
                    running: false
                    repeat: false
                    onTriggered: toastModel.remove(index)
                }

                Rectangle {
                    id: toastInner
                    width: parent.width
                    height: contentRow.implicitHeight + 24
                    radius: 14
                    color: root.theme.name === "dark"
                           ? Qt.rgba(
                               Qt.lighter(model.soft, 1).r,
                               Qt.lighter(model.soft, 1).g,
                               Qt.lighter(model.soft, 1).b, 0.95)
                           : model.soft
                    border.color: model.border_
                    border.width: 1

                    // Left color accent bar
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        anchors.leftMargin: 0
                        width: 4
                        radius: 2
                        color: model.accent
                    }

                    // Bottom countdown strip
                    Rectangle {
                        id: progressStrip
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottomMargin: 0
                        anchors.leftMargin: 4
                        height: 3
                        radius: 1.5
                        color: model.accent
                        opacity: 0.5
                        width: parent.width

                        NumberAnimation on implicitWidth {
                            from: parent.width - 4
                            to: 0
                            duration: 4500
                            running: true
                            easing.type: Easing.Linear
                        }
                    }

                    RowLayout {
                        id: contentRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 20
                        anchors.rightMargin: 14
                        spacing: 12

                        // Icon badge
                        Rectangle {
                            width: 26; height: 26
                            radius: 8
                            color: model.accent
                            Text {
                                anchors.centerIn: parent
                                text: model.icon
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                color: "white"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: model.message
                            color: root.theme.textPrimary
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            wrapMode: Text.WordWrap
                        }

                        // Dismiss X
                        Rectangle {
                            width: 20; height: 20
                            radius: 6
                            color: dismissArea.containsMouse ? root.theme.surface2 : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                font.pixelSize: 14
                                color: root.theme.textMuted
                            }
                            MouseArea {
                                id: dismissArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    exitAnim.start()
                                    removeTimer.start()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
