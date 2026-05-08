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
    readonly property int globeSize: Math.min(width, height)
    readonly property int globeRadius: globeSize / 2
    readonly property int globeCenterX: width / 2
    readonly property int globeCenterY: height / 2
    readonly property var signalNodes: [[51.5, -0.1], [40.7, -74.0], [35.7, 139.7], [1.3, 103.8], [52.5, 13.4], [-33.9, 151.2], [19.4, -99.1], [25.2, 55.3]]

    function wrapLongitude(value) {
        var wrapped = ((value + 180) % 360 + 360) % 360 - 180;
        return wrapped;
    }

    function project(lat, lon) {
        var relativeLon = wrapLongitude(lon - rotationPhase);
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

    readonly property var coastlines: [
        // North America - West Coast
        [[72, -168], [70, -164], [68, -162], [65, -162], [59, -150], [57, -142], [48, -128], [40, -124], [33, -118], [25, -113], [18, -103], [14, -92], [8, -82]],
        // North America - Atlantic Coast
        [[8, -82], [7, -78], [10, -75], [13, -72], [18, -68], [22, -72], [25, -79], [28, -81], [29, -84], [30, -87], [33, -79], [36, -76], [37, -75], [40, -74], [42, -70], [44, -68], [45, -67], [47, -65], [50, -55], [53, -56], [55, -58], [58, -62], [62, -63], [68, -54], [72, -52]],
        // North America - Gulf / Florida
        [[25, -79], [26, -82], [28, -85], [30, -89], [29, -93], [28, -96], [18, -88], [13, -86], [8, -79]],
        // South America - Pacific
        [[8, -79], [3, -80], [-6, -82], [-13, -78], [-16, -76], [-20, -72], [-24, -66], [-28, -60], [-33, -58], [-38, -58], [-44, -58], [-48, -64], [-52, -68], [-55, -72], [-52, -76], [-43, -74], [-35, -68], [-31, -54], [-26, -48], [-20, -46], [-18, -40]],
        // South America - Atlantic
        [[-54, -68], [-55, -50], [-46, -38], [-34, -36], [-15, -39], [-5, -38], [2, -50], [5, -56], [10, -62], [8, -79]],
        // Europe - Scandinavia
        [[72, 12], [70, 20], [72, 28], [68, 34], [64, 36], [60, 24], [58, 14], [56, 8], [52, 4], [48, 2], [44, -2], [38, -10], [36, -6]],
        // Europe - Mainland West
        [[38, -10], [42, -8], [44, -4], [43, -1], [37, 3], [35, -1], [36, -6], [38, -10]],
        // Europe - Mediterranean / Iberia
        [[43, -1], [37, -6], [36, -6], [35, 0], [36, 6], [36, 12], [40, 18], [44, 16], [44, 12], [43, 8], [44, 4], [43, -1]],
        // Europe - Adriatic / Greece
        [[40, 20], [45, 14], [44, 12], [38, 14], [34, 24], [36, 28], [39, 26], [42, 26], [40, 20]],
        // Europe - UK / Ireland
        [[53, -6], [52, -3], [52, 0], [55, -2], [57, -4], [58, -8], [55, -6], [53, -6]],
        [[55, -6], [54, -10], [54, -8], [55, -6]],
        // Africa - Northwest
        [[35, -6], [34, -2], [32, -4], [29, -4], [24, -4], [15, -8], [12, -18], [5, -8], [4, 2], [6, 12]],
        // Africa - West Coast / Gulf of Guinea
        [[5, -8], [6, -10], [6, -12], [8, -14], [12, -18], [12, -20], [8, -14], [6, -12], [6, -8]],
        // Africa - South West
        [[5, 12], [6, 14], [4, 18], [-6, 24], [-12, 20], [-18, 12], [-24, 14], [-30, 14], [-34, 20]],
        // Africa - South / Cape
        [[-34, 20], [-34, 22], [-32, 26], [-28, 32], [-26, 34], [-22, 34], [-18, 32], [-14, 28], [-10, 24], [-6, 18]],
        // Africa - East Coast
        [[5, 12], [8, 14], [10, 22], [12, 28], [10, 38], [4, 42], [-2, 44], [-6, 40], [-12, 34], [-18, 32]],
        // Africa - Horn / Madagascar
        [[10, 38], [12, 44], [12, 52], [6, 46], [-2, 44]],
        [[-18, 32], [-22, 38], [-20, 44], [-18, 46], [-22, 44], [-22, 40], [-20, 36]],
        // Asia - Saudi / Red Sea
        [[10, 44], [14, 42], [16, 40], [18, 38], [14, 36], [12, 32], [12, 28]],
        // Asia - India West
        [[12, 28], [16, 26], [20, 24], [22, 26], [20, 30], [16, 32], [10, 28]],
        // Asia - India East / Bay of Bengal
        [[22, 26], [24, 28], [26, 34], [22, 34], [18, 30], [16, 26]],
        // Asia - Southeast / Thailand / Vietnam
        [[18, 30], [22, 34], [24, 38], [28, 42], [28, 46], [24, 44], [20, 40], [16, 32]],
        // Asia - China East
        [[28, 46], [32, 48], [36, 48], [40, 44], [44, 38], [42, 36], [36, 38], [34, 34], [30, 36], [26, 34]],
        // Asia - Korea / Japan
        [[36, 48], [38, 50], [42, 48], [44, 44]],
        [[38, 46], [38, 42], [42, 40], [44, 38], [40, 36], [38, 38]],
        [[40, 40], [42, 38], [44, 36], [43, 33], [40, 34], [38, 36]],
        // Asia - Kamchatka / Northeast Siberia
        [[44, 44], [48, 50], [54, 52], [58, 54], [62, 56], [66, 56], [68, 50], [64, 42], [58, 42]],
        // Asia - Russian Arctic
        [[72, 28], [74, 42], [76, 68], [72, 74], [68, 70], [64, 64], [62, 52]],
        // Asia - Philippines / Indonesia
        [[34, 44], [36, 42], [44, 36], [48, 32], [50, 28], [44, 24], [38, 22], [32, 22], [28, 18]],
        // Asia - Malaysia / Borneo
        [[32, 22], [34, 18], [40, 18], [44, 14], [48, 14], [44, 10], [38, 10], [34, 12]],
        [[28, 18], [26, 14], [22, 12], [18, 12], [16, 8], [14, 4]],
        // Indonesia - Sumatra / Java
        [[14, 4], [10, 4], [8, 8], [9, 12], [6, 10], [2, 3], [-2, 6], [-4, 8], [-2, 10]],
        [[8, 12], [12, 14], [16, 14], [20, 16], [24, 22]],
        // Indonesia - New Guinea
        [[24, 22], [26, 26], [30, 28], [30, 24], [26, 20]],
        // Australia - North / West
        [[26, 20], [22, 16], [16, 12], [14, 8], [10, -2], [4, -8], [-2, -12], [-6, -14], [-10, -16], [-12, -14], [-14, -10]],
        // Australia - South
        [[-14, -10], [-16, -4], [-18, 2], [-20, 8], [-18, 16], [-14, 18]],
        // Australia - East / Great Barrier
        [[-14, 18], [-11, 16], [-8, 14], [-2, 12], [8, 14], [14, 16], [20, 18], [24, 14]],
        // Australia - Tasmania
        [[-24, 4], [-22, 8], [-20, 10], [-18, 8], [-20, 4]],
        // New Zealand
        [[-36, 174], [-38, 178], [-42, 174], [-43, 170], [-38, 170], [-36, 174]],
        [[-44, 170], [-45, 168], [-46, 170], [-45, 170]],
        // Antarctica
        [[-72, -120], [-72, -60], [-72, 0], [-72, 80], [-72, 150], [-68, 170], [-64, -170], [-68, -90], [-72, -120]],
        // Iceland
        [[64, -24], [66, -18], [64, -12], [63, -18], [62, -24], [64, -24]],
        // Greenland
        [[84, -60], [80, -44], [76, -30], [68, -28], [60, -34], [62, -44], [64, -52], [68, -60], [74, -68], [80, -66], [84, -60]],
        // Sri Lanka
        [[6, 78], [8, 80], [10, 82], [6, 82], [6, 78]],
        // Taiwan
        [[22, 120], [24, 122], [26, 120], [24, 118], [22, 120]],
        // Cuba / Caribbean
        [[22, -80], [24, -78], [22, -76], [20, -76], [18, -78], [18, -80], [20, -84], [22, -80]],
        [[18, -76], [18, -74], [18, -72], [16, -72]],
        // Japan main islands
        [[30, 130], [31, 131], [33, 129], [34, 132], [36, 136], [38, 138], [40, 140], [42, 141], [44, 141], [46, 142], [46, 140], [44, 138], [41, 139], [38, 137], [34, 134], [33, 132], [30, 130]],
        [[44, 142], [46, 142], [46, 146], [44, 146], [42, 144], [44, 142]],
        // Mediterranean Islands
        [[38, 14], [36, 12], [36, 14], [38, 16]],
        [[38, 8], [40, 10], [42, 10], [40, 8]],
        [[30, 32], [32, 34], [34, 32], [32, 30]],
        // Persian Gulf
        [[28, 48], [28, 50], [26, 52], [24, 50], [26, 46]],
        // Black Sea / Turkey
        [[42, 28], [42, 32], [42, 36], [42, 40], [42, 44], [44, 42], [46, 38], [44, 32], [42, 28]],
        [[46, 38], [48, 36], [46, 32], [44, 32]],
        [[38, 30], [36, 34], [36, 38], [32, 36], [26, 36], [22, 30]],
        [[22, 30], [20, 30], [18, 30], [20, 32]],
        // Caspian Sea (as coastline outline)
        [[46, 48], [48, 52], [44, 54], [40, 52], [38, 48], [42, 46], [46, 48]],
        // Scandinavia / Finland
        [[64, 16], [66, 20], [70, 26], [66, 28], [62, 24], [60, 18], [62, 12], [64, 16]],
        // Korean Peninsula
        [[34, 126], [36, 128], [38, 128], [40, 126], [42, 128], [40, 130], [38, 128], [36, 126], [34, 126]],
        // Hokkaido
        [[42, 140], [43, 142], [44, 144], [43, 146], [42, 144], [42, 140]],
        // Aleutians
        [[54, -164], [56, -160], [58, -152], [56, -148], [54, -156], [54, -164]],
        // Hawaii
        [[20, -156], [22, -156], [22, -154], [20, -154]],
        // Galapagos
        [[0, -90], [-1, -90], [-1, -88], [0, -88]],
        // Canary Islands
        [[28, -16], [28, -14], [30, -14], [30, -16]],
        // South Georgia / Falklands
        [[-52, -60], [-54, -58], [-54, -56], [-52, -56]],
        [[-54, -38], [-54, -36], [-56, -36], [-56, -38]],
        // Florida / Bahamas
        [[26, -82], [28, -80], [25, -78], [23, -78], [21, -80], [24, -82]],
        [[25, -78], [24, -76], [22, -74], [18, -76], [20, -78]],
        // Mediterranean Islands detailed
        [[40, -8], [40, -6], [38, -6], [38, -8]],
        [[36, 24], [38, 22], [38, 24], [36, 26]],
        [[40, 16], [42, 18], [42, 20], [40, 20]],
        // Ireland
        [[54, -10], [56, -8], [56, -6], [54, -6], [52, -8], [52, -10], [54, -10]],
        [[54, -10], [52, -10], [52, -12], [54, -12]],
        // Sulawesi
        [[0, 120], [2, 122], [4, 120], [2, 118], [0, 120]],
        // Lesser Sunda Islands
        [[-8, 114], [-8, 120], [-6, 124], [-4, 124], [-6, 118], [-8, 114]],
        [[-10, 122], [-10, 124], [-8, 126], [-6, 124]],
        // Seychelles
        [[-4, 55], [-4, 56], [-2, 56], [-2, 55]],
        // Maldives
        [[4, 72], [4, 74], [2, 74], [2, 72]],
        // New Caledonia
        [[-20, 164], [-22, 166], [-22, 168], [-20, 166]]
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
                var relative = root.wrapLongitude(lon - root.rotationPhase);
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
            ctx.ellipse(cx, cy, radius * 1.14, radius * 0.26, -0.28 + root.rotationPhase * Math.PI / 720, 0, Math.PI * 2);
            ctx.stroke();

            // scan ring inner
            ctx.globalAlpha = root.expanded ? 0.18 : 0.12;
            ctx.beginPath();
            ctx.ellipse(cx, cy, radius * 0.98, radius * 0.18, 0.72 - root.rotationPhase * Math.PI / 900, 0, Math.PI * 2);
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
