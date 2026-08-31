// qml/components/RenameConfirmDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root
    required property var theme
    property int itemCount: 0
    property int usedCount: 0
    property int missingCount: 0
    signal confirmed()

    modal: true
    dim: true
    width: 460
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    background: Rectangle {
        radius: 14
        color: theme.surface
        border.color: theme.border_
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 14

        Text {
            text: "✏️ Confirm Batch Rename"
            font.pixelSize: 16
            font.weight: Font.ExtraBold
            color: theme.textPrimary
        }
        Text {
            text: "About to rename " + root.itemCount + " files:\n  • " + root.usedCount + " → _U suffix\n  • " + root.missingCount + " → _R suffix"
            font.pixelSize: 13
            color: theme.textMuted
            lineHeight: 1.5
        }
        Text {
            text: "⚠️ This operation follows strict safety rules — only files inside\n\"Remaining\" folders will be touched."
            font.pixelSize: 12
            color: theme.accent
            lineHeight: 1.5
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10
            Button {
                text: "Cancel"
                flat: true
                onClicked: root.close()
            }
            Button {
                text: "✏️ Rename Now"
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
