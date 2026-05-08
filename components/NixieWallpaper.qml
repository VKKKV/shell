import "../services"
import "../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real phase: 0
    readonly property string valueText: Qt.formatDateTime(Time.now, "hh.mm.ss")
    readonly property real parallaxX: Math.sin(phase * Math.PI / 180) * 0.18
    readonly property real parallaxY: Math.cos(phase * Math.PI / 240) * 0.12

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
            const glow = ctx.createRadialGradient(cx + root.parallaxX * 120, cy + root.parallaxY * 80, 0, cx, cy, Math.max(width, height) * 0.58);
            glow.addColorStop(0, "#3d230d");
            glow.addColorStop(0.42, "#140b04");
            glow.addColorStop(1, "#000000");
            ctx.globalAlpha = (0.5 + 0.08 * Math.sin(root.phase * Math.PI / 180)) * SettingsService.intensity;
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

            ctx.globalAlpha = 0.18 * SettingsService.intensity;
            ctx.strokeStyle = "#5a3218";
            ctx.lineWidth = Theme.heavyLineWidth;
            ctx.beginPath();
            ctx.moveTo(width * 0.18, height * 0.68);
            ctx.lineTo(width * 0.82, height * 0.68);
            ctx.stroke();
        }
    }

    RowLayout {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.parallaxX * 28
        anchors.verticalCenterOffset: root.parallaxY * 14
        spacing: Math.max(10, Math.min(width, height) * 0.018)
        opacity: 0.92

        Repeater {
            model: root.valueText.length

            Item {
                required property int index

                readonly property string digit: root.valueText.charAt(index)
                readonly property bool separator: digit === "."
                readonly property real tubePulse: 0.5 + 0.5 * Math.sin((root.phase + index * 29) * Math.PI / 180)

                Layout.preferredWidth: separator ? Math.max(20, root.width * 0.017) : Math.max(82, root.width * 0.076)
                Layout.preferredHeight: Math.max(150, root.height * 0.27)

                Rectangle {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    width: parent.width * 1.16
                    height: parent.height * 1.06
                    radius: width * 0.28
                    color: "#110704"
                    border.color: "#2a1609"
                    border.width: Math.max(2, Theme.heavyLineWidth)
                    opacity: 0.9
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    width: parent.width * 0.92
                    height: parent.height
                    radius: width * 0.42
                    color: "#2a1208"
                    border.color: "#9a4f1c"
                    border.width: Math.max(2, Theme.heavyLineWidth)
                    opacity: 0.78
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    width: parent.width * 0.66
                    height: parent.height * 0.88
                    radius: width * 0.5
                    color: "#190b05"
                    border.color: "#ff9b3c"
                    border.width: Theme.lineWidth
                    opacity: 0.24 + parent.tubePulse * 0.08
                }

                Repeater {
                    model: parent.separator ? 0 : 10

                    Text {
                        required property int index

                        anchors.centerIn: parent
                        text: String(index)
                        color: "#6a2f12"
                        opacity: index === Number(parent.digit) ? 0 : 0.12
                        font.family: Theme.fontFamily
                        font.pixelSize: parent.height * 0.53
                        font.bold: true
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: parent.separator ? ":" : parent.digit
                    color: parent.separator ? "#9a5722" : "#ff8b2e"
                    opacity: parent.separator ? 0.72 : 0.96
                    font.family: Theme.fontFamily
                    font.pixelSize: parent.separator ? parent.height * 0.34 : parent.height * 0.58
                    font.bold: true
                }

                Text {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    text: parent.digit
                    color: "#ffd08a"
                    opacity: 0.3 + parent.tubePulse * 0.16
                    font.family: Theme.fontFamily
                    font.pixelSize: parent.height * 0.6
                    font.bold: true
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.centerIn: parent
                    width: parent.width * 0.95
                    height: parent.height * 0.98
                    radius: width * 0.42
                    color: "transparent"
                    border.color: "#ffd08a"
                    border.width: Theme.lineWidth
                    opacity: 0.12
                }

                Rectangle {
                    visible: !parent.separator
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.08
                    width: parent.width * 0.52
                    height: Theme.lineWidth
                    color: "#ffd08a"
                    opacity: 0.34
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

                Rectangle {
                    visible: !parent.separator
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.18
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.08
                    width: Math.max(2, Theme.lineWidth)
                    height: parent.height * 0.8
                    color: "#fff0bd"
                    opacity: 0.08
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
