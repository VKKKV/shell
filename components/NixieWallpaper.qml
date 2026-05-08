import "../services"
import "../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real phase: 0
    readonly property string valueText: Qt.formatDateTime(Time.now, "hh.mm.ss")

    NumberAnimation on phase {
        from: 0
        to: 360
        duration: 9000
        loops: Animation.Infinite
        running: root.visible
    }

    Canvas {
        id: backdropCanvas

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            const cx = width * 0.5;
            const cy = height * 0.5;
            const glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, Math.max(width, height) * 0.55);
            glow.addColorStop(0, "#33220c");
            glow.addColorStop(0.4, "#140b04");
            glow.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.48 * SettingsService.intensity;
            ctx.fillStyle = glow;
            ctx.fillRect(0, 0, width, height);

            ctx.globalAlpha = 0.08 * SettingsService.intensity;
            ctx.strokeStyle = Theme.lineDim.toString();
            ctx.lineWidth = Theme.lineWidth;
            for (let x = 0; x < width; x += 96) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x + Math.sin((root.phase + x) * Math.PI / 180) * 12, height);
                ctx.stroke();
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: Math.max(10, Math.min(width, height) * 0.018)
        opacity: 0.88

        Repeater {
            model: root.valueText.length

            Item {
                required property int index

                readonly property string digit: root.valueText.charAt(index)
                readonly property bool separator: digit === "."

                Layout.preferredWidth: separator ? Math.max(18, root.width * 0.018) : Math.max(70, root.width * 0.07)
                Layout.preferredHeight: Math.max(130, root.height * 0.24)

                Rectangle {
                    visible: !parent.separator
                    anchors.fill: parent
                    radius: width * 0.18
                    color: "#221007"
                    border.color: "#5a3218"
                    border.width: Math.max(2, Theme.heavyLineWidth)
                    opacity: 0.72
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    width: parent.width * 0.78
                    height: parent.height * 0.9
                    radius: width * 0.5
                    color: "transparent"
                    border.color: "#c06a2a"
                    border.width: Theme.lineWidth
                    opacity: 0.32
                }

                Text {
                    anchors.centerIn: parent
                    text: parent.separator ? ":" : parent.digit
                    color: parent.separator ? "#9a5722" : "#ff8b2e"
                    opacity: parent.separator ? 0.72 : 0.95
                    font.family: Theme.fontFamily
                    font.pixelSize: parent.separator ? parent.height * 0.34 : parent.height * 0.56
                    font.bold: true
                }

                Text {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    text: parent.digit
                    color: "#ffd08a"
                    opacity: 0.26 + 0.08 * Math.sin((root.phase + parent.index * 31) * Math.PI / 180)
                    font.family: Theme.fontFamily
                    font.pixelSize: parent.height * 0.56
                    font.bold: true
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.08
                    width: parent.width * 0.52
                    height: Theme.lineWidth
                    color: "#ffd08a"
                    opacity: 0.28
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: parent.height * 0.1
                    width: parent.width * 0.5
                    height: Theme.lineWidth
                    color: "#7a3c16"
                    opacity: 0.42
                }
            }
        }
    }

    TacticalLabel {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: Math.max(110, parent.height * 0.18)
        text: "NIXIE WALLPAPER // LOCAL TIME // DIVERGENCE METER INSPIRED"
        accent: true
        opacity: 0.42
    }

    onPhaseChanged: backdropCanvas.requestPaint()
    onWidthChanged: backdropCanvas.requestPaint()
    onHeightChanged: backdropCanvas.requestPaint()
}
