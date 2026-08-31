// ============================================================
// qml/components/ConfettiEffect.qml
// Premium Multi-Color Confetti Burst
// ============================================================
import QtQuick
import QtQuick.Particles

Item {
    id: root
    z: 9998

    function trigger() {
        emitter1.burst(80)
        burstTimer.start()
    }

    // Second delayed burst for cascade effect
    Timer {
        id: burstTimer
        interval: 150
        repeat: false
        running: false
        onTriggered: emitter2.burst(50)
    }

    ParticleSystem {
        id: ps
        anchors.fill: parent
    }

    // Rectangular confetti
    ItemParticle {
        system: ps
        delegate: Rectangle {
            id: confPiece
            width: 9 + Math.random() * 7
            height: 5 + Math.random() * 5
            radius: Math.random() > 0.5 ? width / 2 : 2
            color: Qt.hsla(Math.random(), 0.75, 0.58, 1.0)
            rotation: Math.random() * 360

            NumberAnimation on rotation {
                from: 0; to: Math.random() > 0.5 ? 540 : -360
                duration: 1800 + Math.random() * 800
                running: true
                loops: 1
            }
        }
    }

    // Primary emitter — top center spread
    Emitter {
        id: emitter1
        system: ps
        x: root.width / 2
        y: root.height * 0.12
        width: root.width * 0.7
        height: 4
        anchors.horizontalCenter: parent.horizontalCenter

        emitRate: 0
        lifeSpan: 3200
        lifeSpanVariation: 700
        size: 12
        sizeVariation: 5

        velocity: AngleDirection {
            angle: 270
            angleVariation: 55
            magnitude: 400
            magnitudeVariation: 120
        }
        acceleration: PointDirection { y: 320 }
    }

    // Secondary emitter — wider side-scatter
    Emitter {
        id: emitter2
        system: ps
        x: root.width / 2
        y: root.height * 0.08
        width: root.width * 0.5
        height: 4

        emitRate: 0
        lifeSpan: 2800
        lifeSpanVariation: 500
        size: 8
        sizeVariation: 4

        velocity: AngleDirection {
            angle: 270
            angleVariation: 75
            magnitude: 300
            magnitudeVariation: 100
        }
        acceleration: PointDirection { y: 260 }
    }
}
