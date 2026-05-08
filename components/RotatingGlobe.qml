import "EarthCoastlineData.js" as EarthCoastlineData
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
    signal hoverEntered()
    signal hoverExited()
    property real manualLongitudeOffset: 0

    implicitWidth: 180
    implicitHeight: 180
    readonly property int globeSize: Math.min(width, height)
    readonly property int globeRadius: globeSize / 2
    readonly property int globeCenterX: width / 2
    readonly property int globeCenterY: height / 2
    readonly property var signalNodes: [[51.5, -0.1], [40.7, -74.0], [35.7, 139.7], [1.3, 103.8], [52.5, 13.4], [-33.9, 151.2], [19.4, -99.1], [25.2, 55.3]]
    readonly property var coastlines: EarthCoastlineData.coastlines

    function wrapLongitude(value) {
        var wrapped = ((value + 180) % 360 + 360) % 360 - 180;
        return wrapped;
    }

    function displayRotationPhase() {
        return wrapLongitude(rotationPhase + manualLongitudeOffset);
    }

    function project(lat, lon) {
        var relativeLon = wrapLongitude(lon - displayRotationPhase());
        var lonRad = relativeLon * Math.PI / 180;
        var latRad = lat * Math.PI / 180;
        var visible = Math.cos(lonRad) >= -0.08;
        return {
            x: globeCenterX + Math.sin(lonRad) * Math.cos(latRad) * globeRadius * 0.84,
            y: globeCenterY - Math.sin(latRad) * globeRadius * 0.76,
            visible: visible,
            edge: Math.max(0.25, Math.cos(lonRad))
        };
    }

    function drawPolyline(ctx, points, color, alpha, width) {
        var open = false;
        ctx.strokeStyle = color;
        ctx.lineWidth = width;
        ctx.globalAlpha = alpha;
        ctx.beginPath();
        for (var i = 0; i < points.length; i++) {
            var point = project(points[i][0], points[i][1]);
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

    function drawProjectedNode(ctx, lat, lon, radius, color, alpha) {
        var point = project(lat, lon);
        if (!point.visible) return;
        ctx.globalAlpha = alpha * point.edge;
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(point.x, point.y, radius, 0, Math.PI * 2);
        ctx.fill();
    }

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
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            var radius = root.globeRadius * 0.94;
            var cx = root.globeCenterX;
            var cy = root.globeCenterY;
            var accent = Theme.line.toString();
            var dim = Theme.lineDim.toString();
            var text = Theme.text.toString();
            var danger = Theme.danger.toString();
            var displayPhase = root.displayRotationPhase();

            ctx.save();
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            // ocean fill
            var fill = ctx.createRadialGradient(cx - radius * 0.28, cy - radius * 0.34, radius * 0.08, cx, cy, radius);
            fill.addColorStop(0, "#1a2a22");
            fill.addColorStop(0.42, "#08120e");
            fill.addColorStop(1, "#000000");
            ctx.globalAlpha = 0.94;
            ctx.fillStyle = fill;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.fill();

            ctx.save();
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.clip();

            // ocean grid - latitude lines
            ctx.strokeStyle = dim;
            ctx.lineWidth = Math.max(0.7, Theme.lineWidth);
            for (var lat = -60; lat <= 60; lat += 30) {
                var y = cy - Math.sin(lat * Math.PI / 180) * radius * 0.76;
                var w = Math.cos(lat * Math.PI / 180) * radius * 1.68;
                ctx.globalAlpha = lat === 0 ? 0.36 : 0.22;
                ctx.beginPath();
                ctx.ellipse(cx, y, w / 2, radius * 0.06, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            // ocean grid - longitude lines
            for (var lon = -150; lon <= 180; lon += 30) {
                var relative = root.wrapLongitude(lon - displayPhase);
                var x = cx + Math.sin(relative * Math.PI / 180) * radius * 0.84;
                var alpha = Math.max(0.08, Math.cos(relative * Math.PI / 180) * 0.22);
                ctx.globalAlpha = alpha;
                ctx.beginPath();
                ctx.ellipse(x, cy, Math.max(2, Math.abs(Math.cos(relative * Math.PI / 180)) * radius * 0.14), radius * 0.8, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            // fine latitude grid
            ctx.globalAlpha = root.expanded ? 0.16 : 0.1;
            ctx.strokeStyle = accent;
            ctx.lineWidth = Math.max(0.6, Theme.lineWidth);
            for (var latFine = -75; latFine <= 75; latFine += 15) {
                y = cy - Math.sin(latFine * Math.PI / 180) * radius * 0.76;
                w = Math.cos(latFine * Math.PI / 180) * radius * 1.68;
                ctx.beginPath();
                ctx.ellipse(cx, y, w / 2, radius * 0.035, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            // land mass fill
            ctx.globalAlpha = 0.14;
            ctx.fillStyle = accent;
            for (var c = 0; c < root.coastlines.length; c++) {
                var pts = root.coastlines[c];
                if (pts.length < 4) continue;
                var first = root.project(pts[0][0], pts[0][1]);
                var last = root.project(pts[pts.length - 1][0], pts[pts.length - 1][1]);
                if (!first.visible || !last.visible) continue;
                ctx.beginPath();
                ctx.moveTo(first.x, first.y);
                for (var i = 1; i < pts.length; i++) {
                    var pt = root.project(pts[i][0], pts[i][1]);
                    if (pt.visible) ctx.lineTo(pt.x, pt.y);
                }
                ctx.fill();
            }

            // coastline strokes
            for (c = 0; c < root.coastlines.length; c++)
                root.drawPolyline(ctx, root.coastlines[c], accent, root.expanded ? 0.82 : 0.68, root.expanded ? 2.0 : 1.4);

            // signal nodes
            ctx.globalCompositeOperation = "screen";
            for (var n = 0; n < root.signalNodes.length; n++)
                root.drawProjectedNode(ctx, root.signalNodes[n][0], root.signalNodes[n][1], root.expanded ? 3.2 : 2.2, accent, root.expanded ? 0.58 : 0.42);
            ctx.globalCompositeOperation = "source-over";

            // night terminator
            var night = ctx.createLinearGradient(cx + radius * 0.18, cy - radius, cx + radius * 0.88, cy + radius);
            night.addColorStop(0, "#00000000");
            night.addColorStop(0.45, "#22000000");
            night.addColorStop(1, "#cc000000");
            ctx.globalAlpha = 0.7;
            ctx.fillStyle = night;
            ctx.fillRect(cx - radius, cy - radius, radius * 2, radius * 2);

            ctx.restore();

            // scan ring outer
            ctx.globalAlpha = root.expanded ? 0.22 : 0.16;
            ctx.strokeStyle = accent;
            ctx.lineWidth = Theme.lineWidth;
            ctx.beginPath();
            ctx.ellipse(cx, cy, radius * 1.14, radius * 0.26, -0.28 + displayPhase * Math.PI / 720, 0, Math.PI * 2);
            ctx.stroke();

            // scan ring inner
            ctx.globalAlpha = root.expanded ? 0.18 : 0.12;
            ctx.beginPath();
            ctx.ellipse(cx, cy, radius * 0.98, radius * 0.18, 0.72 - displayPhase * Math.PI / 900, 0, Math.PI * 2);
            ctx.stroke();

            // outer globe ring
            ctx.globalAlpha = 0.95;
            ctx.strokeStyle = accent;
            ctx.lineWidth = root.expanded ? Math.max(3, Theme.heavyLineWidth + 1) : Theme.heavyLineWidth;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.stroke();

            // secondary outer ring
            ctx.globalAlpha = 0.28;
            ctx.strokeStyle = dim;
            ctx.lineWidth = Theme.lineWidth;
            ctx.beginPath();
            ctx.arc(cx, cy, radius * 1.08, -0.45, Math.PI * 1.26);
            ctx.stroke();

            // location marker
            if (root.locationAvailable) {
                var marker = root.project(root.latitude, root.longitude);
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

            // labels
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
    onManualLongitudeOffsetChanged: globeCanvas.requestPaint()
    onLocationAvailableChanged: globeCanvas.requestPaint()
    onExpandedChanged: globeCanvas.requestPaint()
    onWidthChanged: globeCanvas.requestPaint()
    onHeightChanged: globeCanvas.requestPaint()

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        preventStealing: true

        property real pressX: 0
        property real startOffset: 0
        property bool dragged: false

        onEntered: root.hoverEntered()
        onExited: root.hoverExited()

        onPressed: function(mouse) {
            pressX = mouse.x;
            startOffset = root.manualLongitudeOffset;
            dragged = false;
        }

        onPositionChanged: function(mouse) {
            if (!pressed)
                return;

            var deltaX = mouse.x - pressX;
            if (Math.abs(deltaX) < 3)
                return;

            dragged = true;
            root.manualLongitudeOffset = root.wrapLongitude(startOffset + deltaX * 0.9);
        }

        onReleased: function(mouse) {
            if (!dragged)
                root.activated();
        }
    }
}
