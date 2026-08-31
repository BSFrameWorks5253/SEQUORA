// qml/components/ApprovedBanner.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var theme
    height: 60
    radius: 12
    color: theme.successSoft
    border.color: theme.success
    border.width: 1

    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 12

        Text {
            text: "✅"
            font.pixelSize: 22
        }
        ColumnLayout {
            spacing: 2
            Text {
                text: "All video clips successfully matched! Ready to transfer."
                font.pixelSize: 14
                font.weight: Font.ExtraBold
                color: theme.success
            }
            Text {
                text: "Review the matched pairs below and click Execute Transfer to proceed."
                font.pixelSize: 12
                color: theme.success
                opacity: 0.85
            }
        }
    }
}
