// ============================================================
// qml/components/StudioIcon.qml
// Pixel-Perfect Vector Icons for SEQUORA Studio (Lucide/Linear standard)
// ============================================================
import QtQuick

Item {
    id: root

    property string name: "overview"
    property color  color: "#8B5CF6"
    property real   size: 18

    width: size
    height: size

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        smooth: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            var w = width
            var h = height
            var scale = w / 24.0

            ctx.save()
            ctx.scale(scale, scale)
            ctx.strokeStyle = root.color
            ctx.fillStyle = root.color
            ctx.lineWidth = 1.8
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var n = root.name

            if (n === "overview" || n === "dashboard" || n === "grid") {
                // 4-grid squares
                ctx.strokeRect(3, 3, 7, 7)
                ctx.strokeRect(14, 3, 7, 7)
                ctx.strokeRect(3, 14, 7, 7)
                ctx.strokeRect(14, 14, 7, 7)
            }
            else if (n === "photo" || n === "camera" || n === "photoMatcher") {
                // Pro Camera
                ctx.beginPath()
                ctx.moveTo(7, 6)
                ctx.lineTo(9, 4)
                ctx.lineTo(15, 4)
                ctx.lineTo(17, 6)
                ctx.lineTo(20, 6)
                ctx.arcTo(22, 6, 22, 8, 2)
                ctx.lineTo(22, 18)
                ctx.arcTo(22, 20, 20, 20, 2)
                ctx.lineTo(4, 20)
                ctx.arcTo(2, 20, 2, 18, 2)
                ctx.lineTo(2, 8)
                ctx.arcTo(2, 6, 4, 6, 2)
                ctx.closePath()
                ctx.stroke()

                // Lens
                ctx.beginPath()
                ctx.arc(12, 13, 3.5, 0, Math.PI * 2)
                ctx.stroke()
            }
            else if (n === "video" || n === "clapper" || n === "videoTransfer") {
                // Clapperboard
                ctx.beginPath()
                ctx.moveTo(4, 8)
                ctx.lineTo(20, 8)
                ctx.arcTo(22, 8, 22, 10, 2)
                ctx.lineTo(22, 18)
                ctx.arcTo(22, 20, 20, 20, 2)
                ctx.lineTo(4, 20)
                ctx.arcTo(2, 20, 2, 18, 2)
                ctx.lineTo(2, 10)
                ctx.arcTo(2, 8, 4, 8, 2)
                ctx.closePath()
                ctx.stroke()

                // Slanted clapper top
                ctx.beginPath()
                ctx.moveTo(2, 8)
                ctx.lineTo(4, 4)
                ctx.lineTo(20, 4)
                ctx.lineTo(22, 8)
                ctx.stroke()

                // Stripes
                ctx.beginPath()
                ctx.moveTo(8, 4); ctx.lineTo(10, 8)
                ctx.moveTo(14, 4); ctx.lineTo(16, 8)
                ctx.stroke()

                // Play triangle inside
                ctx.beginPath()
                ctx.moveTo(10, 11)
                ctx.lineTo(15, 14)
                ctx.lineTo(10, 17)
                ctx.closePath()
                ctx.fill()
            }
            else if (n === "pvSeparator" || n === "package" || n === "box") {
                // Isometric Media Package Box
                ctx.beginPath()
                ctx.moveTo(12, 2)
                ctx.lineTo(21, 7)
                ctx.lineTo(21, 17)
                ctx.lineTo(12, 22)
                ctx.lineTo(3, 17)
                ctx.lineTo(3, 7)
                ctx.closePath()
                ctx.stroke()

                // Box fold lines
                ctx.beginPath()
                ctx.moveTo(12, 2); ctx.lineTo(12, 12)
                ctx.moveTo(12, 12); ctx.lineTo(21, 7)
                ctx.moveTo(12, 12); ctx.lineTo(3, 7)
                ctx.moveTo(12, 12); ctx.lineTo(12, 22)
                ctx.stroke()
            }
            else if (n === "remainingCollector" || n === "folder-stack" || n === "layers") {
                // Multi-Folder Shifter Stack
                ctx.beginPath()
                ctx.moveTo(2, 9)
                ctx.lineTo(7, 9)
                ctx.lineTo(9, 11)
                ctx.lineTo(20, 11)
                ctx.arcTo(22, 11, 22, 13, 2)
                ctx.lineTo(22, 19)
                ctx.arcTo(22, 21, 20, 21, 2)
                ctx.lineTo(4, 21)
                ctx.arcTo(2, 21, 2, 19, 2)
                ctx.closePath()
                ctx.stroke()

                // Top layer folder tab
                ctx.beginPath()
                ctx.moveTo(5, 5)
                ctx.lineTo(9, 5)
                ctx.lineTo(11, 7)
                ctx.lineTo(19, 7)
                ctx.stroke()
            }
            else if (n === "excelMerger" || n === "report" || n === "chart") {
                // Bar Analytics / Report
                ctx.strokeRect(3, 3, 18, 18)
                // Bar 1
                ctx.fillRect(6, 12, 3, 6)
                // Bar 2
                ctx.fillRect(11, 8, 3, 10)
                // Bar 3
                ctx.fillRect(16, 14, 3, 4)
            }
            else if (n === "cloud" || n === "googleDriveMain") {
                // Cloud with drive sync
                ctx.beginPath()
                ctx.moveTo(7, 18)
                ctx.arcTo(2, 18, 2, 13, 3)
                ctx.arcTo(2, 10, 6, 10, 3)
                ctx.arcTo(8, 4, 15, 4, 5)
                ctx.arcTo(21, 6, 21, 12, 4)
                ctx.arcTo(22, 18, 17, 18, 3)
                ctx.closePath()
                ctx.stroke()

                // Center sync arrow
                ctx.beginPath()
                ctx.moveTo(12, 11); ctx.lineTo(12, 16)
                ctx.moveTo(9.5, 13.5); ctx.lineTo(12, 11); ctx.lineTo(14.5, 13.5)
                ctx.stroke()
            }
            else if (n === "thumbs" || n === "googleDriveThumbs") {
                // Reference preview drive (Folder + image)
                ctx.beginPath()
                ctx.moveTo(2, 6)
                ctx.lineTo(8, 6)
                ctx.lineTo(10, 8)
                ctx.lineTo(20, 8)
                ctx.arcTo(22, 8, 22, 10, 2)
                ctx.lineTo(22, 18)
                ctx.arcTo(22, 20, 20, 20, 2)
                ctx.lineTo(4, 20)
                ctx.arcTo(2, 20, 2, 18, 2)
                ctx.closePath()
                ctx.stroke()

                // Small photo circle inside
                ctx.beginPath()
                ctx.arc(15, 14, 2, 0, Math.PI * 2)
                ctx.stroke()
            }
            else if (n === "activity" || n === "clock" || n === "pulse") {
                // Studio Activity Timeline Clock
                ctx.beginPath()
                ctx.arc(12, 12, 9, 0, Math.PI * 2)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(12, 6); ctx.lineTo(12, 12); ctx.lineTo(16, 14)
                ctx.stroke()
            }
            else if (n === "settings" || n === "gear") {
                // Settings Gear
                ctx.beginPath()
                ctx.arc(12, 12, 4, 0, Math.PI * 2)
                ctx.stroke()

                // Teeth
                for (var i = 0; i < 6; i++) {
                    var angle = i * (Math.PI / 3)
                    var x1 = 12 + Math.cos(angle) * 6
                    var y1 = 12 + Math.sin(angle) * 6
                    var x2 = 12 + Math.cos(angle) * 8.5
                    var y2 = 12 + Math.sin(angle) * 8.5
                    ctx.beginPath()
                    ctx.moveTo(x1, y1)
                    ctx.lineTo(x2, y2)
                    ctx.stroke()
                }
            }

            ctx.restore()
        }
    }

    onColorChanged: canvas.requestPaint()
    onNameChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()
}
