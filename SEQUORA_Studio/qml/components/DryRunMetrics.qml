// qml/components/DryRunMetrics.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var theme
    property var result: null

    height: 52
    radius: 10
    color: result && !result.hasSufficientSpace ? theme.dangerSoft : theme.successSoft
    border.color: result && !result.hasSufficientSpace ? theme.danger : theme.success
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 16

        Text {
            text: result && !result.hasSufficientSpace ? "⚠️" : "✅"
            font.pixelSize: 18
        }
        Text {
            text: result ? (result.fileCount + " files / " + (result.totalBytes / 1048576).toFixed(1) + " MB to copy") : ""
            font.pixelSize: 13
            font.weight: Font.Bold
            color: theme.textPrimary
        }
        Text {
            text: result && result.freeBytes >= 0 ? ("Free space: " + (result.freeBytes / 1073741824).toFixed(2) + " GB") : ""
            font.pixelSize: 12
            color: theme.textMuted
        }
        Text {
            visible: result && !result.hasSufficientSpace
            text: "⚠️ Insufficient disk space!"
            font.pixelSize: 13
            font.weight: Font.ExtraBold
            color: theme.danger
        }
    }
}
