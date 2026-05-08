import "../services"
import "../theme"
import QtQuick

Item {
    id: root

    property real phase: 0
    readonly property string valueText: Qt.formatDateTime(Time.now, "hh.mm.ss")
    readonly property real tubeWidth: Math.max(70, Math.min(root.width * 0.076, root.height * 0.14))
    readonly property real tubeHeight: tubeWidth * 2.2
    readonly property real tubeGap: Math.max(14, tubeWidth * 0.16)
    readonly property real colonWidth: Math.max(20, tubeWidth * 0.22)
    readonly property real totalWidth: 6 * tubeWidth + 2 * colonWidth + 7 * tubeGap
    readonly property real areaX: (root.width - totalWidth) * 0.5
    readonly property real areaY: (root.height - tubeHeight) * 0.5

    NumberAnimation on phase {
        from: 0; to: 360
        duration: 9000
        loops: Animation.Infinite
        running: root.visible
    }

    Canvas {
        id: bgCanvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            const cx = width * 0.5;
            const cy = height * 0.5;
            const glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, Math.max(width, height) * 0.48);
            glow.addColorStop(0, "#1a0c04");
            glow.addColorStop(0.38, "#0a0401");
            glow.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.7;
            ctx.fillStyle = glow;
            ctx.fillRect(0, 0, width, height);
        }
    }

    Canvas {
        id: tubesCanvas
        anchors.fill: parent
        antialiasing: true

        function drawTubeDigit(ctx, x, y, w, h, digit, pulse) {
            ctx.save();
            ctx.translate(x, y);

            // tube body
            const rx = w * 0.32;
            ctx.fillStyle = "#0a0301";
            ctx.globalAlpha = 0.92;
            ctx.beginPath();
            ctx.moveTo(rx, 0);
            ctx.lineTo(w - rx, 0);
            ctx.arcTo(w, 0, w, rx, rx);
            ctx.lineTo(w, h - rx);
            ctx.arcTo(w, h, w - rx, h, rx);
            ctx.lineTo(rx, h);
            ctx.arcTo(0, h, 0, h - rx, rx);
            ctx.lineTo(0, rx);
            ctx.arcTo(0, 0, rx, 0, rx);
            ctx.fill();

            // glass border
            ctx.globalAlpha = 0.55 + pulse * 0.12;
            ctx.strokeStyle = "#4a2a16";
            ctx.lineWidth = 2;
            ctx.stroke();

            // inner glass ring
            ctx.globalAlpha = 0.22 + pulse * 0.06;
            ctx.strokeStyle = "#6a3c1a";
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(rx + 4, 4);
            ctx.lineTo(w - rx - 4, 4);
            ctx.arcTo(w - 4, 4, w - 4, rx + 4, rx - 4);
            ctx.lineTo(w - 4, h - rx - 4);
            ctx.arcTo(w - 4, h - 4, w - rx - 4, h - 4, rx - 4);
            ctx.lineTo(rx + 4, h - 4);
            ctx.arcTo(4, h - 4, 4, h - rx - 4, rx - 4);
            ctx.lineTo(4, rx + 4);
            ctx.arcTo(4, 4, rx + 4, 4, rx - 4);
            ctx.stroke();

            // anode grid top
            ctx.globalAlpha = 0.18;
            ctx.strokeStyle = "#995a2c";
            ctx.lineWidth = 0.8;
            for (let gx = w * 0.18; gx < w * 0.85; gx += w * 0.08) {
                ctx.beginPath();
                ctx.moveTo(gx, h * 0.08);
                ctx.lineTo(gx, h * 0.16);
                ctx.stroke();
            }

            // faint ghost digits - all 10 stacked
            const fontSize = h * 0.5;
            ctx.globalAlpha = 0.07;
            ctx.fillStyle = "#c06a2a";
            ctx.font = fontSize + "px " + Theme.fontFamily;
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            const dig = Number(digit);
            for (let i = 0; i < 10; i++) {
                if (i === dig) continue;
                ctx.fillText(String(i), w * 0.5, h * 0.5);
            }

            // lit digit - primary glow layer
            ctx.globalAlpha = 0.42 + pulse * 0.18;
            ctx.fillStyle = "#ff7a20";
            ctx.font = "bold " + fontSize + "px " + Theme.fontFamily;
            ctx.fillText(digit, w * 0.5, h * 0.5);

            // lit digit - core bright layer
            ctx.globalAlpha = 0.88 + pulse * 0.1;
            ctx.fillStyle = "#ffaa3c";
            ctx.font = fontSize + "px " + Theme.fontFamily;
            ctx.fillText(digit, w * 0.5, h * 0.5);

            // bottom electrode
            ctx.globalAlpha = 0.24;
            ctx.fillStyle = "#c06a2a";
            ctx.beginPath();
            ctx.arc(w * 0.5, h * 0.9, w * 0.07, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 0.14;
            ctx.strokeStyle = "#d08040";
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(w * 0.5, h * 0.9);
            ctx.lineTo(w * 0.5, h * 0.96);
            ctx.stroke();

            // glass reflection streak
            ctx.globalAlpha = 0.06;
            ctx.strokeStyle = "#ffffff";
            ctx.lineWidth = 1.2;
            ctx.beginPath();
            ctx.moveTo(w * 0.22, h * 0.12);
            ctx.lineTo(w * 0.22, h * 0.78);
            ctx.stroke();

            ctx.restore();
        }

        function drawColon(ctx, x, y, w, h) {
            const dotR = Math.max(3, w * 0.18);
            ctx.save();
            ctx.fillStyle = "#ff8b2e";
            ctx.globalAlpha = 0.6;
            ctx.beginPath();
            ctx.arc(x + w * 0.5, y + h * 0.35, dotR, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 0.8;
            ctx.beginPath();
            ctx.arc(x + w * 0.5, y + h * 0.35, dotR * 0.5, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 0.6;
            ctx.beginPath();
            ctx.arc(x + w * 0.5, y + h * 0.62, dotR, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 0.8;
            ctx.beginPath();
            ctx.arc(x + w * 0.5, y + h * 0.62, dotR * 0.5, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            const tw = root.tubeWidth;
            const th = root.tubeHeight;
            const gap = root.tubeGap;
            const cw = root.colonWidth;
            let posX = root.areaX;

            for (let i = 0; i < root.valueText.length; i++) {
                const ch = root.valueText.charAt(i);
                const pulse = 0.5 + 0.5 * Math.sin((root.phase + i * 31) * Math.PI / 180);

                if (ch === ".") {
                    posX += gap;
                    drawColon(ctx, posX, root.areaY, cw, th);
                    posX += cw + gap;
                } else {
                    posX += gap;
                    drawTubeDigit(ctx, posX, root.areaY, tw, th, ch, pulse);
                    posX += tw;
                }
            }
        }
    }

    onPhaseChanged: { bgCanvas.requestPaint(); tubesCanvas.requestPaint(); }
    onWidthChanged: { bgCanvas.requestPaint(); tubesCanvas.requestPaint(); }
    onHeightChanged: { bgCanvas.requestPaint(); tubesCanvas.requestPaint(); }
}
