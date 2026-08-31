// qml/components/ConfirmDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root
    required property var    theme
    title:                       "Confirm"
    property string message:     ""
    property string confirmText: "Confirm"
    property string cancelText:  "Cancel"

    signal confirmed()
    signal cancelled()

    modal: true
    dim: true
    x: (parent.width  - width)  / 2
    y: (parent.height - height) / 2
    width: 420

    background: Rectangle {
        radius: 14
        color: theme.surface
        border.color: theme.border_
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 12

        Text {
            text: root.title
            font.pixelSize: 16
            font.weight: Font.ExtraBold
            color: theme.textPrimary
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        Text {
            text: root.message
            font.pixelSize: 13
            color: theme.textMuted
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            visible: root.message !== ""
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignRight
            Button {
                text: root.cancelText
                flat: true
                onClicked: {
                    root.close()
                    root.cancelled()
                }
            }
            Button {
                text: root.confirmText
                highlighted: true
                Material.accent: theme.accent
                onClicked: {
                    root.close()
                    root.confirmed()
                }
            }
        }
    }
}
