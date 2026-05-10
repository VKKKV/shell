import "../services"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real phase: 0
    readonly property string valueText: Qt.formatDateTime(Time.now, "hh.mm.ss")
    readonly property int digitHeight: Math.max(140, Math.min(root.height * 0.35, root.width * 0.12))
    readonly property int digitWidth: Math.round(digitHeight * 0.34)
    readonly property int gap: Math.max(8, Math.round(digitWidth * 0.18))
    readonly property string digitsDir: Qt.resolvedUrl("../assets/nixie/").toString()

    function imageFor(character: string): string {
        return root.digitsDir + (character === "." ? "p" : character) + ".png";
    }

    NumberAnimation on phase {
        from: 0; to: 360
        duration: 9000
        loops: Animation.Infinite
        running: root.visible
    }

    Rectangle {
        anchors.fill: parent
        color: "#010101"
    }

    Canvas {
        id: ambientCanvas

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            var cx = width * 0.5, cy = height * 0.5;
            var glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, Math.max(width, height) * 0.62);
            glow.addColorStop(0, "#1b0902");
            glow.addColorStop(0.38, "#090301");
            glow.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.72;
            ctx.fillStyle = glow;
            ctx.fillRect(0, 0, width, height);

            var halo = ctx.createRadialGradient(cx, cy, 0, cx, cy, Math.max(width, height) * 0.28);
            halo.addColorStop(0, "#ff6b1a");
            halo.addColorStop(0.36, "#4a1604");
            halo.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.1;
            ctx.fillStyle = halo;
            ctx.fillRect(0, 0, width, height);

            ctx.globalAlpha = 0.035;
            ctx.fillStyle = "#f06f1e";
            for (var y = 0; y < height; y += 5) {
                var offset = Math.sin((root.phase + y) * Math.PI / 180) * 0.5;
                ctx.fillRect(0, y + offset, width, 1);
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
                readonly property real pulse: 0.5 + 0.5 * Math.sin((root.phase + index * 31) * Math.PI / 180)
                readonly property string slotImage: root.imageFor(digit)

                Layout.preferredWidth: root.digitWidth
                Layout.preferredHeight: root.digitHeight
                Layout.leftMargin: index === 0 ? 0 : root.gap

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 1.22
                    height: parent.height * 1.06
                    source: parent.slotImage
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: 0.12 + parent.pulse * 0.04
                }

                Image {
                    anchors.fill: parent
                    source: parent.slotImage
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: 0.86 + parent.pulse * 0.08
                }
            }
        }
    }

    onPhaseChanged: ambientCanvas.requestPaint()
    onWidthChanged: ambientCanvas.requestPaint()
    onHeightChanged: ambientCanvas.requestPaint()
}
