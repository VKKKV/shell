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
    readonly property real surfaceRadius: globeRadius * (expanded ? 0.945 : 0.93)
    readonly property real frameRadius: globeRadius * (expanded ? 0.96 : 0.945)
    // Keep expanded repaint work bounded so opening the central Earth panel does
    // not stall on every reviewed coastline point. The current 50m data remains
    // the runtime source; 10m candidates are too large for stride-1 activation.
    readonly property int coastlinePolylineStride: expanded ? 1 : (globeSize < 165 ? 4 : 3)
    readonly property int coastlinePointStride: expanded ? 2 : (globeSize < 165 ? 5 : 4)
    readonly property int landPolylineStride: expanded ? 2 : (globeSize < 165 ? 8 : 6)
    readonly property int terrainPointStride: expanded ? 4 : (globeSize < 165 ? 12 : 9)
    readonly property int minRenderedPolylinePoints: expanded ? 2 : (globeSize < 165 ? 10 : 7)
    readonly property int textureLatStep: expanded ? 10 : 20
    readonly property int textureLonStep: expanded ? 15 : 30
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

    function drawPolyline(ctx, points, color, alpha, width, pointStride) {
        if (points.length < root.minRenderedPolylinePoints)
            return;

        var open = false;
        var drawn = 0;
        ctx.strokeStyle = color;
        ctx.lineWidth = width;
        ctx.globalAlpha = alpha;
        ctx.beginPath();
        for (var i = 0; i < points.length; i += Math.max(1, pointStride)) {
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
            drawn++;
        }
        if (drawn >= 2)
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

    function terrainNoise(lat, lon) {
        var value = Math.sin(lat * 12.9898 + lon * 78.233) * 43758.5453;
        return value - Math.floor(value);
    }

    function terrainRidgeNoise(lat, lon) {
        var primary = terrainNoise(lat * 0.73 + 11.0, lon * 0.61 - 7.0);
        var secondary = terrainNoise(lat * 1.31 - 5.0, lon * 1.17 + 19.0);
        return primary * 0.62 + secondary * 0.38;
    }

    function isClosedPolyline(points) {
        if (points.length < 4)
            return false;

        var first = points[0];
        var last = points[points.length - 1];
        var latDistance = first[0] - last[0];
        var lonDistance = wrapLongitude(first[1] - last[1]);
        return Math.sqrt(latDistance * latDistance + lonDistance * lonDistance) <= 0.45;
    }

    function buildVisibleCoastlinePath(ctx, points, pointStride) {
        var open = false;
        var count = 0;
        ctx.beginPath();
        for (var i = 0; i < points.length; i += Math.max(1, pointStride)) {
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
            count++;
        }
        return count >= 4;
    }

    function drawOceanTexture(ctx, radius, accent, dim, displayPhase) {
        ctx.save();
        ctx.globalCompositeOperation = "screen";
        ctx.strokeStyle = dim;
        ctx.lineWidth = Math.max(0.5, Theme.lineWidth * 0.7);
        for (var lat = -75; lat <= 75; lat += root.textureLatStep) {
            for (var lon = -180; lon < 180; lon += root.textureLonStep) {
                var sampleLon = lon + displayPhase * 0.18;
                var textureProjected = project(lat, sampleLon);
                if (!textureProjected.visible)
                    continue;

                var textureNoise = terrainNoise(lat, lon);
                if (textureNoise < 0.42)
                    continue;

                var textureLength = radius * (0.012 + textureNoise * 0.018);
                ctx.globalAlpha = (root.expanded ? 0.09 : 0.055) * textureProjected.edge;
                ctx.beginPath();
                ctx.moveTo(textureProjected.x - textureLength, textureProjected.y + textureLength * 0.35);
                ctx.lineTo(textureProjected.x + textureLength, textureProjected.y - textureLength * 0.35);
                ctx.stroke();
            }
        }

        if (root.expanded) {
            var bathymetryLatStep = 9;
            var bathymetryLonStep = 14;
            ctx.strokeStyle = accent;
            ctx.lineWidth = Math.max(0.45, Theme.lineWidth * 0.45);
            for (var bathyLat = -72; bathyLat <= 72; bathyLat += bathymetryLatStep) {
                for (var bathyLon = -174; bathyLon < 180; bathyLon += bathymetryLonStep) {
                    var bathySampleLon = bathyLon - displayPhase * 0.12;
                    var bathyProjected = project(bathyLat, bathySampleLon);
                    if (!bathyProjected.visible)
                        continue;

                    var bathyNoise = terrainRidgeNoise(bathyLat, bathyLon);
                    if (bathyNoise < 0.7)
                        continue;

                    var bathyLength = radius * (0.008 + bathyNoise * 0.013);
                    var bathyTilt = terrainNoise(bathyLat - 17, bathyLon + 23) - 0.5;
                    ctx.globalAlpha = 0.07 * bathyProjected.edge;
                    ctx.beginPath();
                    ctx.moveTo(bathyProjected.x - bathyLength, bathyProjected.y + bathyLength * bathyTilt);
                    ctx.lineTo(bathyProjected.x + bathyLength, bathyProjected.y - bathyLength * bathyTilt);
                    ctx.stroke();
                }
            }
        }

        ctx.fillStyle = accent;
        for (var band = -60; band <= 60; band += 30) {
            for (var meridian = -165; meridian < 180; meridian += 30) {
                var gridProjected = project(band + 5, meridian - displayPhase * 0.1);
                if (!gridProjected.visible)
                    continue;
                ctx.globalAlpha = (root.expanded ? 0.045 : 0.03) * gridProjected.edge;
                ctx.beginPath();
                ctx.arc(gridProjected.x, gridProjected.y, Math.max(0.7, radius * 0.008), 0, Math.PI * 2);
                ctx.fill();
            }
        }
        ctx.restore();
    }

    function drawCoastalRelief(ctx, pts, terrain) {
        var reliefStride = root.expanded ? 4 : (root.globeSize < 165 ? 18 : 14);
        ctx.strokeStyle = terrain;
        ctx.lineWidth = Math.max(0.45, Theme.lineWidth * 0.5);

        for (var i = 0; i < pts.length; i += reliefStride) {
            var point = project(pts[i][0], pts[i][1]);
            if (!point.visible)
                continue;

            var ridge = terrainRidgeNoise(pts[i][0], pts[i][1]);
            if (ridge < 0.6)
                continue;

            var run = root.globeRadius * (0.014 + ridge * 0.016);
            var slant = terrainNoise(pts[i][0] + 31, pts[i][1] - 29) - 0.5;
            ctx.globalAlpha = (root.expanded ? 0.105 : 0.05) * point.edge;
            ctx.beginPath();
            ctx.moveTo(point.x - run, point.y + run * slant);
            ctx.lineTo(point.x + run, point.y - run * slant);
            ctx.stroke();
        }
    }

    function drawCoastlineHierarchy(ctx, accent, dim) {
        for (var c = 0; c < root.coastlines.length; c += root.coastlinePolylineStride) {
            var pts = root.coastlines[c];
            var major = root.expanded && pts.length >= 72;
            var visibleAlpha = major ? 0.86 : (root.expanded ? 0.72 : 0.64);
            var visibleWidth = major ? 2.15 : (root.expanded ? 1.55 : 1.25);

            if (major)
                root.drawPolyline(ctx, pts, dim, 0.22, 3.2, root.coastlinePointStride);

            root.drawPolyline(ctx, pts, accent, visibleAlpha, visibleWidth, root.coastlinePointStride);
        }
    }

    function drawLandMasses(ctx, accent, terrain) {
        for (var c = 0; c < root.coastlines.length; c += root.landPolylineStride) {
            var pts = root.coastlines[c];
            if (pts.length < Math.max(4, root.minRenderedPolylinePoints) || !isClosedPolyline(pts))
                continue;

            var first = root.project(pts[0][0], pts[0][1]);
            var last = root.project(pts[pts.length - 1][0], pts[pts.length - 1][1]);
            if (!first.visible || !last.visible)
                continue;

            if (!buildVisibleCoastlinePath(ctx, pts, root.coastlinePointStride))
                continue;

            ctx.globalAlpha = 0.13;
            ctx.fillStyle = accent;
            ctx.fill();

            if (!terrain)
                continue;

            ctx.save();
            ctx.clip();

            ctx.globalCompositeOperation = "screen";
            ctx.strokeStyle = terrain;
            ctx.lineWidth = Math.max(0.45, Theme.lineWidth * 0.55);
            ctx.globalAlpha = root.expanded ? 0.1 : 0.065;
            for (var line = -3; line <= 3; line++) {
                ctx.beginPath();
                ctx.ellipse(root.globeCenterX + line * root.globeRadius * 0.16, root.globeCenterY, root.globeRadius * 0.38, root.globeRadius * 0.12, -0.42, 0, Math.PI * 2);
                ctx.stroke();
            }

            ctx.fillStyle = terrain;
            for (var i = 0; i < pts.length; i += root.terrainPointStride) {
                var point = project(pts[i][0], pts[i][1]);
                if (!point.visible)
                    continue;
                var noise = terrainNoise(pts[i][0], pts[i][1]);
                if (noise < (root.expanded ? 0.42 : 0.36))
                    continue;
                ctx.globalAlpha = (root.expanded ? 0.085 : 0.055) * point.edge;
                ctx.beginPath();
                ctx.arc(point.x, point.y, 0.7 + noise * (root.expanded ? 1.0 : 0.9), 0, Math.PI * 2);
                ctx.fill();
            }

            if (root.expanded)
                drawCoastalRelief(ctx, pts, terrain);
            ctx.restore();
        }
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
            var radius = root.surfaceRadius;
            var frameRadius = root.frameRadius;
            var cx = root.globeCenterX;
            var cy = root.globeCenterY;
            var accent = Theme.line.toString();
            var dim = Theme.lineDim.toString();
            var text = Theme.text.toString();
            var danger = Theme.danger.toString();
            var terrain = Theme.terminalGreen.toString();
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
            ctx.arc(cx, cy, frameRadius, 0, Math.PI * 2);
            ctx.fill();

            // atmospheric rim glow
            var atmosphere = ctx.createRadialGradient(cx - radius * 0.08, cy - radius * 0.1, radius * 0.68, cx, cy, radius * 1.1);
            atmosphere.addColorStop(0, "#00000000");
            atmosphere.addColorStop(0.72, Theme.alphaColor(Theme.line.toString(), root.expanded ? 0.035 : 0.03));
            atmosphere.addColorStop(0.9, Theme.alphaColor(Theme.terminalGreen.toString(), root.expanded ? 0.12 : 0.075));
            atmosphere.addColorStop(1, Theme.alphaColor(Theme.line.toString(), root.expanded ? 0.34 : 0.22));
            ctx.globalCompositeOperation = "screen";
            ctx.globalAlpha = 1;
            ctx.fillStyle = atmosphere;
            ctx.beginPath();
            ctx.arc(cx, cy, radius * 1.06, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalCompositeOperation = "source-over";

            ctx.save();
            ctx.beginPath();
            ctx.arc(cx, cy, frameRadius - Math.max(1, Theme.lineWidth * 0.5), 0, Math.PI * 2);
            ctx.clip();

            // procedural ocean depth/detail texture
            root.drawOceanTexture(ctx, radius, accent, dim, displayPhase);

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

            // land mass fill with clipped procedural terrain hints
            root.drawLandMasses(ctx, accent, terrain);

            // coastline strokes
            root.drawCoastlineHierarchy(ctx, accent, dim);

            // signal nodes
            ctx.globalCompositeOperation = "screen";
            for (var n = 0; n < root.signalNodes.length; n++)
                root.drawProjectedNode(ctx, root.signalNodes[n][0], root.signalNodes[n][1], root.expanded ? 3.2 : 2.2, accent, root.expanded ? 0.58 : 0.42);
            ctx.globalCompositeOperation = "source-over";

            // night terminator
            var night = ctx.createLinearGradient(cx + radius * 0.08, cy - radius, cx + radius * 0.92, cy + radius);
            night.addColorStop(0, "#00000000");
            night.addColorStop(0.42, "#18000000");
            night.addColorStop(0.74, "#72000000");
            night.addColorStop(1, "#c9000000");
            ctx.globalAlpha = root.expanded ? 0.66 : 0.7;
            ctx.fillStyle = night;
            ctx.fillRect(cx - radius, cy - radius, radius * 2, radius * 2);

            if (root.expanded) {
                var dusk = ctx.createLinearGradient(cx + radius * 0.24, cy - radius * 0.86, cx + radius * 0.68, cy + radius * 0.86);
                dusk.addColorStop(0, "#00000000");
                dusk.addColorStop(0.5, Theme.alphaColor(Theme.line.toString(), 0.1));
                dusk.addColorStop(1, "#00000000");
                ctx.globalCompositeOperation = "screen";
                ctx.globalAlpha = 0.38;
                ctx.fillStyle = dusk;
                ctx.fillRect(cx - radius, cy - radius, radius * 2, radius * 2);
                ctx.globalCompositeOperation = "source-over";
            }

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
            ctx.lineWidth = root.expanded ? Math.max(3, Theme.heavyLineWidth + 1) : Math.max(2, Theme.heavyLineWidth);
            ctx.beginPath();
            ctx.arc(cx, cy, frameRadius, 0, Math.PI * 2);
            ctx.stroke();

            // inner rim hides Canvas clip antialias seams between the surface and frame.
            ctx.globalAlpha = root.expanded ? 0.48 : 0.38;
            ctx.strokeStyle = Theme.alphaColor("#000000", 0.65);
            ctx.lineWidth = root.expanded ? Math.max(2, Theme.lineWidth + 1) : Math.max(1.5, Theme.lineWidth);
            ctx.beginPath();
            ctx.arc(cx, cy, frameRadius - ctx.lineWidth * 0.5, 0, Math.PI * 2);
            ctx.stroke();

            // secondary outer ring
            ctx.globalAlpha = 0.28;
            ctx.strokeStyle = dim;
            ctx.lineWidth = Theme.lineWidth;
            ctx.beginPath();
            ctx.arc(cx, cy, frameRadius * 1.08, -0.45, Math.PI * 1.26);
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
