import "../services"
import "../theme"
import QtQuick

Item {
    id: root

    property string label: "AGENT CORE"
    property string statusText: "PROVIDER // PLACEHOLDER"
    property bool expanded: false
    signal activated()

    implicitWidth: 180
    implicitHeight: 180
    readonly property real sphereSize: Math.min(width, height)
    readonly property real radius: sphereSize * 0.42
    readonly property real centerX: width * 0.5
    readonly property real centerY: height * 0.5
    property real phase: 0
    property real yaw: 0
    property real pitch: -14
    property real dragStartYaw: 0
    property real dragStartPitch: 0
    property real dragPressX: 0
    property real dragPressY: 0
    property bool dragActive: false
    property real hoverX: centerX
    property real hoverY: centerY

    readonly property var nodes: [
        [-0.84, -0.42, -0.18], [-0.62, -0.08, 0.48], [-0.58, 0.38, -0.36], [-0.34, -0.68, 0.28], [-0.18, 0.7, 0.18],
        [0.02, -0.32, -0.76], [0.16, 0.18, 0.72], [0.34, -0.74, -0.12], [0.48, 0.48, -0.42], [0.66, -0.16, 0.36],
        [0.82, 0.22, -0.08], [-0.08, -0.9, -0.08], [0.08, 0.9, 0.08], [-0.74, 0.14, 0.12], [0.72, -0.48, -0.28],
        [-0.32, -0.2, 0.82], [0.3, 0.66, 0.42], [-0.04, 0.02, -0.98]
    ]

    function rotateNode(node: var): var {
        const yawRad = (yaw + phase * (dragActive ? 0.12 : 0.32)) * Math.PI / 180;
        const pitchRad = pitch * Math.PI / 180;
        const cosYaw = Math.cos(yawRad);
        const sinYaw = Math.sin(yawRad);
        const cosPitch = Math.cos(pitchRad);
        const sinPitch = Math.sin(pitchRad);
        const x1 = node[0] * cosYaw - node[2] * sinYaw;
        const z1 = node[0] * sinYaw + node[2] * cosYaw;
        const y2 = node[1] * cosPitch - z1 * sinPitch;
        const z2 = node[1] * sinPitch + z1 * cosPitch;
        const hoverPull = meshArea.containsMouse ? Math.max(0, 1 - Math.hypot(centerX + x1 * radius - hoverX, centerY + y2 * radius - hoverY) / radius) : 0;
        const scale = 1 + hoverPull * 0.08;
        const perspective = 1 / (1.35 - z2 * 0.32);
        return {
            x: centerX + x1 * radius * perspective * scale,
            y: centerY + y2 * radius * perspective * scale,
            z: z2,
            p: perspective,
            pulse: hoverPull
        };
    }

    NumberAnimation on phase {
        from: 0
        to: 360
        duration: expanded ? 18000 : 14000
        loops: Animation.Infinite
        running: root.visible && !root.dragActive
    }

    Canvas {
        id: meshCanvas

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            const accent = Theme.line.toString();
            const dim = Theme.lineDim.toString();
            const text = Theme.text.toString();
            const danger = Theme.danger.toString();
            const projected = [];
            for (let i = 0; i < root.nodes.length; i++)
                projected.push(root.rotateNode(root.nodes[i]));

            ctx.save();
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            const fill = ctx.createRadialGradient(root.centerX - root.radius * 0.28, root.centerY - root.radius * 0.36, root.radius * 0.12, root.centerX, root.centerY, root.radius * 1.18);
            fill.addColorStop(0, "#1d241f");
            fill.addColorStop(0.5, "#07100d");
            fill.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.7;
            ctx.fillStyle = fill;
            ctx.beginPath();
            ctx.arc(root.centerX, root.centerY, root.radius * 1.08, 0, Math.PI * 2);
            ctx.fill();

            ctx.globalAlpha = meshArea.containsMouse ? 0.55 : 0.34;
            ctx.strokeStyle = dim;
            ctx.lineWidth = Theme.lineWidth;
            ctx.beginPath();
            ctx.arc(root.centerX, root.centerY, root.radius * 1.12, 0, Math.PI * 2);
            ctx.stroke();
            ctx.globalAlpha = 0.2;
            ctx.beginPath();
            ctx.arc(root.centerX, root.centerY, root.radius * 0.78, -0.3, Math.PI * 1.65);
            ctx.stroke();

            for (let i = 0; i < projected.length; i++) {
                for (let j = i + 1; j < projected.length; j++) {
                    const source = root.nodes[i];
                    const target = root.nodes[j];
                    const dist = Math.hypot(source[0] - target[0], source[1] - target[1], source[2] - target[2]);
                    if (dist > 0.92)
                        continue;
                    const a = projected[i];
                    const b = projected[j];
                    const front = Math.max(0, (a.z + b.z + 1.5) / 3);
                    ctx.globalAlpha = Math.min(0.7, 0.13 + front * 0.28 + Math.max(a.pulse, b.pulse) * 0.36);
                    ctx.strokeStyle = Math.max(a.pulse, b.pulse) > 0.2 ? accent : dim;
                    ctx.lineWidth = Math.max(Theme.lineWidth, front * 1.8);
                    ctx.beginPath();
                    ctx.moveTo(a.x, a.y);
                    ctx.lineTo(b.x, b.y);
                    ctx.stroke();
                }
            }

            for (let i = 0; i < projected.length; i++) {
                const node = projected[i];
                const front = Math.max(0.18, (node.z + 1) * 0.5);
                const hot = i % 7 === 0;
                ctx.globalAlpha = Math.min(1, 0.38 + front * 0.5 + node.pulse * 0.35);
                ctx.fillStyle = hot ? danger : accent;
                ctx.beginPath();
                ctx.arc(node.x, node.y, (expanded ? 4.2 : 3.2) + front * 2.2 + node.pulse * 3.5, 0, Math.PI * 2);
                ctx.fill();
            }

            ctx.globalAlpha = 0.36;
            ctx.fillStyle = text;
            ctx.font = (expanded ? Theme.fontSmall : Theme.fontTiny) + "px " + Theme.fontFamily;
            ctx.textAlign = "center";
            ctx.fillText(root.label, root.centerX, root.centerY - root.radius * 0.64);
            if (expanded)
                ctx.fillText(root.statusText, root.centerX, root.centerY + root.radius * 0.72);
            ctx.restore();
        }
    }

    onPhaseChanged: meshCanvas.requestPaint()
    onYawChanged: meshCanvas.requestPaint()
    onPitchChanged: meshCanvas.requestPaint()
    onWidthChanged: meshCanvas.requestPaint()
    onHeightChanged: meshCanvas.requestPaint()
    onExpandedChanged: meshCanvas.requestPaint()

    MouseArea {
        id: meshArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onPositionChanged: (mouse) => {
            root.hoverX = mouse.x;
            root.hoverY = mouse.y;
            if (root.dragActive) {
                root.yaw = root.dragStartYaw + (mouse.x - root.dragPressX) * 0.55;
                root.pitch = Math.max(-62, Math.min(62, root.dragStartPitch + (mouse.y - root.dragPressY) * 0.38));
            }
            root.meshCanvas.requestPaint();
        }
        onEntered: TooltipService.show("AGENT CORE", "Open the visual agent neural mesh panel. Provider selection is staged as a placeholder until the backend contract is defined.", "agent-core")
        onExited: {
            TooltipService.clear("agent-core");
            root.meshCanvas.requestPaint();
        }
        onPressed: (mouse) => {
            root.dragActive = true;
            root.dragStartYaw = root.yaw;
            root.dragStartPitch = root.pitch;
            root.dragPressX = mouse.x;
            root.dragPressY = mouse.y;
        }
        onReleased: root.dragActive = false
        onCanceled: root.dragActive = false
        onClicked: root.activated()
    }
}
