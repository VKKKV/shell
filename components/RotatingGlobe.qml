import "../theme"
import QtQuick

Item {
    id: root

    property real rotationPhase: 0
    property real latitude: 0
    property real longitude: 0
    property bool locationAvailable: false
    property bool expanded: false
    property string label: "EARTH GEO"
    property string statusText: "IP GEOLOCATION STANDBY"
    signal activated()

    implicitWidth: 180
    implicitHeight: 180
    readonly property real globeSize: Math.min(width, height)
    readonly property real globeRadius: globeSize * 0.5
    readonly property real globeCenterX: width * 0.5
    readonly property real globeCenterY: height * 0.5
    readonly property var signalNodes: [[51.5, -0.1], [40.7, -74.0], [35.7, 139.7], [1.3, 103.8], [52.5, 13.4], [-33.9, 151.2], [19.4, -99.1], [25.2, 55.3]]

    function wrapLongitude(value: real): real {
        const wrapped = ((value + 180) % 360 + 360) % 360 - 180;
        return wrapped;
    }

    function project(lat: real, lon: real): var {
        const relativeLon = wrapLongitude(lon - rotationPhase);
        const lonRad = relativeLon * Math.PI / 180;
        const latRad = lat * Math.PI / 180;
        const visible = Math.cos(lonRad) >= -0.08;
        return {
            x: globeCenterX + Math.sin(lonRad) * Math.cos(latRad) * globeRadius * 0.84,
            y: globeCenterY - Math.sin(latRad) * globeRadius * 0.76,
            visible,
            edge: Math.max(0.25, Math.cos(lonRad))
        };
    }

    function drawPolyline(ctx: var, points: var, color: string, alpha: real, width: real): void {
        let open = false;
        ctx.strokeStyle = color;
        ctx.lineWidth = width;
        ctx.globalAlpha = alpha;
        ctx.beginPath();
        for (let i = 0; i < points.length; i++) {
            const point = project(points[i][0], points[i][1]);
            if (!point.visible) {
                open = false;
                continue;
            }
            if (!open) {
                ctx.moveTo(point.x, point.y);
                open = true;
            } else {
                ctx.lineTo(point.x, point.y);
            }
        }
        ctx.stroke();
    }

    function drawProjectedNode(ctx: var, lat: real, lon: real, radius: real, color: string, alpha: real): void {
        const point = project(lat, lon);
        if (!point.visible)
            return;
        ctx.globalAlpha = alpha * point.edge;
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(point.x, point.y, radius, 0, Math.PI * 2);
        ctx.fill();
    }

    readonly property var coastlines: [
        [[72, -168], [58, -150], [50, -128], [33, -118], [18, -103], [8, -82], [-6, -79], [-18, -74], [-34, -72], [-53, -69]],
        [[70, -52], [56, -78], [46, -66], [34, -77], [25, -81], [18, -88], [9, -78]],
        [[12, -81], [6, -74], [-4, -80], [-16, -76], [-34, -58], [-51, -68], [-55, -50], [-34, -38], [-15, -39], [2, -50], [10, -62]],
        [[36, -10], [52, 0], [60, 18], [70, 32], [58, 50], [44, 38], [36, 20], [31, 10], [36, -10]],
        [[31, -9], [35, 12], [31, 32], [12, 44], [-6, 39], [-22, 28], [-35, 18], [-34, 7], [-18, -6], [2, -16], [18, -17], [31, -9]],
        [[66, 32], [58, 60], [51, 92], [56, 124], [46, 142], [30, 122], [22, 98], [8, 80], [1, 104], [-7, 110], [-10, 75], [8, 44], [28, 50], [43, 70], [54, 92]],
        [[8, 95], [-2, 108], [-8, 124], [-6, 140], [8, 126], [18, 110], [8, 95]],
        [[-11, 113], [-23, 115], [-34, 130], [-39, 146], [-28, 154], [-16, 145], [-11, 130], [-11, 113]],
        [[72, -42], [78, -20], [74, 18], [67, 26], [62, -10], [72, -42]],
        [[36, 128], [42, 142], [44, 154], [36, 140], [36, 128]]
    ]

    NumberAnimation on rotationPhase {
        from: 0
        to: 360
        duration: expanded ? 26000 : 18000
        loops: Animation.Infinite
        running: root.visible
    }

    Canvas {
        id: globeCanvas

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            const radius = root.globeRadius * 0.94;
            const cx = root.globeCenterX;
            const cy = root.globeCenterY;
            const accent = Theme.line.toString();
            const dim = Theme.lineDim.toString();
            const text = Theme.text.toString();
            const danger = Theme.danger.toString();

            ctx.save();
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            const fill = ctx.createRadialGradient(cx - radius * 0.28, cy - radius * 0.34, radius * 0.08, cx, cy, radius);
            fill.addColorStop(0, "#203126");
            fill.addColorStop(0.45, "#07110f");
            fill.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.92;
            ctx.fillStyle = fill;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.fill();

            ctx.save();
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.clip();

            ctx.strokeStyle = dim;
            ctx.lineWidth = Math.max(0.7, Theme.lineWidth);
            for (let lat = -60; lat <= 60; lat += 30) {
                const y = cy - Math.sin(lat * Math.PI / 180) * radius * 0.76;
                const w = Math.cos(lat * Math.PI / 180) * radius * 1.68;
                ctx.globalAlpha = lat === 0 ? 0.36 : 0.22;
                ctx.beginPath();
                ctx.ellipse(cx, y, w / 2, radius * 0.06, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            for (let lon = -150; lon <= 180; lon += 30) {
                const relative = root.wrapLongitude(lon - root.rotationPhase);
                const x = cx + Math.sin(relative * Math.PI / 180) * radius * 0.84;
                const alpha = Math.max(0.08, Math.cos(relative * Math.PI / 180) * 0.22);
                ctx.globalAlpha = alpha;
                ctx.beginPath();
                ctx.ellipse(x, cy, Math.max(2, Math.abs(Math.cos(relative * Math.PI / 180)) * radius * 0.14), radius * 0.8, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            ctx.globalAlpha = root.expanded ? 0.16 : 0.1;
            ctx.strokeStyle = accent;
            ctx.lineWidth = Math.max(0.6, Theme.lineWidth);
            for (let latFine = -75; latFine <= 75; latFine += 15) {
                const y = cy - Math.sin(latFine * Math.PI / 180) * radius * 0.76;
                const w = Math.cos(latFine * Math.PI / 180) * radius * 1.68;
                ctx.beginPath();
                ctx.ellipse(cx, y, w / 2, radius * 0.035, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            for (let c = 0; c < root.coastlines.length; c++)
                root.drawPolyline(ctx, root.coastlines[c], accent, root.expanded ? 0.74 : 0.62, root.expanded ? 2.0 : 1.35);

            ctx.globalCompositeOperation = "screen";
            for (let n = 0; n < root.signalNodes.length; n++)
                root.drawProjectedNode(ctx, root.signalNodes[n][0], root.signalNodes[n][1], root.expanded ? 3.2 : 2.2, accent, root.expanded ? 0.58 : 0.42);
            ctx.globalCompositeOperation = "source-over";

            const night = ctx.createLinearGradient(cx + radius * 0.18, cy - radius, cx + radius * 0.88, cy + radius);
            night.addColorStop(0, "#00000000");
            night.addColorStop(0.45, "#22000000");
            night.addColorStop(1, "#cc000000");
            ctx.globalAlpha = 0.7;
            ctx.fillStyle = night;
            ctx.fillRect(cx - radius, cy - radius, radius * 2, radius * 2);

            ctx.restore();

            ctx.globalAlpha = root.expanded ? 0.22 : 0.16;
            ctx.strokeStyle = accent;
            ctx.lineWidth = Theme.lineWidth;
            ctx.beginPath();
            ctx.ellipse(cx, cy, radius * 1.14, radius * 0.26, -0.28 + root.rotationPhase * Math.PI / 720, 0, Math.PI * 2);
            ctx.stroke();

            ctx.globalAlpha = root.expanded ? 0.18 : 0.12;
            ctx.beginPath();
            ctx.ellipse(cx, cy, radius * 0.98, radius * 0.18, 0.72 - root.rotationPhase * Math.PI / 900, 0, Math.PI * 2);
            ctx.stroke();

            ctx.globalAlpha = 0.95;
            ctx.strokeStyle = accent;
            ctx.lineWidth = root.expanded ? Math.max(3, Theme.heavyLineWidth + 1) : Theme.heavyLineWidth;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.stroke();

            ctx.globalAlpha = 0.28;
            ctx.strokeStyle = dim;
            ctx.lineWidth = Theme.lineWidth;
            ctx.beginPath();
            ctx.arc(cx, cy, radius * 1.08, -0.45, Math.PI * 1.26);
            ctx.stroke();

            if (root.locationAvailable) {
                const marker = root.project(root.latitude, root.longitude);
                if (marker.visible) {
                    ctx.globalAlpha = 0.86;
                    ctx.strokeStyle = danger;
                    ctx.lineWidth = root.expanded ? 2.2 : 1.5;
                    ctx.beginPath();
                    ctx.arc(marker.x, marker.y, root.expanded ? 13 : 8, 0, Math.PI * 2);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(marker.x - (root.expanded ? 18 : 11), marker.y);
                    ctx.lineTo(marker.x + (root.expanded ? 18 : 11), marker.y);
                    ctx.moveTo(marker.x, marker.y - (root.expanded ? 18 : 11));
                    ctx.lineTo(marker.x, marker.y + (root.expanded ? 18 : 11));
                    ctx.stroke();
                    ctx.globalAlpha = 0.95;
                    ctx.fillStyle = danger;
                    ctx.beginPath();
                    ctx.arc(marker.x, marker.y, root.expanded ? 4 : 3, 0, Math.PI * 2);
                    ctx.fill();
                }
            }

            ctx.globalAlpha = 0.32;
            ctx.fillStyle = text;
            ctx.font = (root.expanded ? Theme.fontSmall : Theme.fontTiny) + "px " + Theme.fontFamily;
            ctx.textAlign = "center";
            ctx.fillText(root.label, cx, cy - radius * 0.62);
            if (root.expanded)
                ctx.fillText(root.statusText, cx, cy + radius * 0.7);

            ctx.restore();
        }
    }

    onRotationPhaseChanged: globeCanvas.requestPaint()
    onLatitudeChanged: globeCanvas.requestPaint()
    onLongitudeChanged: globeCanvas.requestPaint()
    onLocationAvailableChanged: globeCanvas.requestPaint()
    onExpandedChanged: globeCanvas.requestPaint()
    onWidthChanged: globeCanvas.requestPaint()
    onHeightChanged: globeCanvas.requestPaint()

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.activated()
    }
}
