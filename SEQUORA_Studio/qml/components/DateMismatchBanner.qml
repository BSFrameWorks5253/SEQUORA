// qml/components/DateMismatchBanner.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var theme
    property var videoDates: []
    property var photoDates: []

    height: bannerCol.implicitHeight + 24
    radius: 12
    color: theme.dangerSoft
    border.color: theme.danger
    border.width: 1

    ColumnLayout {
        id: bannerCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 6

        Text {
            text: "⚠️ Date Folder Mismatch Detected"
            font.pixelSize: 14
            font.weight: Font.ExtraBold
            color: theme.danger
        }
        Text {
            text: "Video dates: " + videoDates.join(", ")
            font.pixelSize: 12
            color: theme.danger
            opacity: 0.9
        }
        Text {
            text: "Photo dates: " + photoDates.join(", ")
            font.pixelSize: 12
            color: theme.danger
            opacity: 0.9
        }
        Text {
            text: "Ensure video and photo folders are labelled with the same date names."
            font.pixelSize: 12
            color: theme.danger
            opacity: 0.75
        }
    }
}
