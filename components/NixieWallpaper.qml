import "../services"
import "../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real phase: 0
    readonly property string valueText: Qt.formatDateTime(Time.now, "hh.mm.ss")
    readonly property int digitHeight: Math.max(140, Math.min(root.height * 0.35, root.width * 0.12))
    readonly property int digitWidth: Math.round(digitHeight * 0.62)
    readonly property int colonWidth: Math.max(16, Math.round(digitWidth * 0.22))
    readonly property int gap: Math.max(8, Math.round(digitWidth * 0.16))
    readonly property int totalWidth: 6 * (digitWidth + gap) + 2 * (colonWidth + gap) - gap
    readonly property int startX: Math.round((root.width - totalWidth) / 2)
    readonly property int startY: Math.round((root.height - digitHeight) / 2)
    readonly property string digitsDir: Qt.resolvedUrl("../assets/nixie/").toString()

    NumberAnimation on phase {
        from: 0; to: 360
        duration: 9000
        loops: Animation.Infinite
        running: root.visible
    }

    Canvas {
        id: backdropCanvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            var cx = width * 0.5, cy = height * 0.5;
            var glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, Math.max(width, height) * 0.55);
            glow.addColorStop(0, "#0d0502");
            glow.addColorStop(0.5, "#050201");
            glow.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.85;
            ctx.fillStyle = glow;
            ctx.fillRect(0, 0, width, height);

            ctx.globalAlpha = 0.06;
            ctx.strokeStyle = Theme.lineDim.toString();
            ctx.lineWidth = Theme.lineWidth;
            for (var x = 0; x < width; x += 112) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x + Math.sin((root.phase + x) * Math.PI / 180) * 12, height);
                ctx.stroke();
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 0
        opacity: 0.94

        Repeater {
            model: 8

            Item {
                required property int index

                readonly property string digit: root.valueText.charAt(index)
                readonly property bool isColon: digit === "."
                readonly property real pulse: 0.5 + 0.5 * Math.sin((root.phase + index * 28) * Math.PI / 180)
                readonly property string digitImage: isColon ? "p.png" : digit + ".png"

                Layout.preferredWidth: isColon ? root.colonWidth : root.digitWidth
                Layout.preferredHeight: root.digitHeight

                Item {
                    visible: isColon
                    anchors.fill: parent
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.12
                        width: parent.width * 0.9
                        height: parent.height * 0.28
                        source: root.digitsDir + "/" + parent.parent.digitImage
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.55 + parent.parent.pulse * 0.22
                    }
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: parent.height * 0.12
                        width: parent.width * 0.9
                        height: parent.height * 0.28
                        source: root.digitsDir + "/" + parent.parent.digitImage
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.55 + parent.parent.pulse * 0.22
                    }
                }

                Item {
                    visible: !isColon
                    anchors.fill: parent

                    // outer metal box
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 1.12
                        height: parent.height * 1.05
                        radius: width * 0.22
                        color: "#0c0402"
                        border.color: "#2a1609"
                        border.width: Math.max(2, Theme.heavyLineWidth)
                        opacity: 0.88
                    }

                    // inner glass tube body
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.96
                        height: parent.height * 0.98
                        radius: width * 0.36
                        color: "#0a0401"
                        border.color: "#5a2c14"
                        border.width: Math.max(2, Theme.heavyLineWidth)
                        opacity: 0.8
                    }

                    // inner glass rim
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.88
                        height: parent.height * 0.94
                        radius: width * 0.38
                        color: "transparent"
                        border.color: "#9a4f1c"
                        border.width: Theme.lineWidth
                        opacity: 0.14 + parent.pulse * 0.06
                    }

                    // digit image
                    Image {
                        anchors.centerIn: parent
                        width: parent.width * 0.76
                        height: parent.height * 0.82
                        source: root.digitsDir + "/" + parent.digitImage
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.88 + parent.pulse * 0.1
                    }

                    // glow overlay
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.72
                        height: parent.height * 0.76
                        radius: width * 0.5
                        color: "#ff7a20"
                        opacity: 0.04 + parent.pulse * 0.03
                    }

                    // top anode wire
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.04
                        width: parent.width * 0.55
                        height: Math.max(1, Theme.lineWidth)
                        color: "#ffd08a"
                        opacity: 0.22
                    }

                    // bottom electrode
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: parent.height * 0.06
                        width: parent.width * 0.2
                        height: Math.max(4, Theme.heavyLineWidth + 2)
                        color: "#c06a2a"
                        opacity: 0.26
                    }

                    // glass reflection
                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * 0.15
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.1
                        width: Math.max(1.5, Theme.lineWidth)
                        height: parent.height * 0.7
                        color: "#ffffff"
                        opacity: 0.05
                    }

                    // bottom pin
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -parent.height * 0.02
                        width: parent.width * 0.16
                        height: parent.height * 0.04
                        color: "#5a2c14"
                        radius: 2
                        opacity: 0.6
                    }
                }
            }
        }
    }

    onPhaseChanged: backdropCanvas.requestPaint()
    onWidthChanged: backdropCanvas.requestPaint()
    onHeightChanged: backdropCanvas.requestPaint()
}
