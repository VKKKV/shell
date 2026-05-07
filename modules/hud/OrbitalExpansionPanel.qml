import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property real dayMs: 86400000
    readonly property date epochJ2000: new Date(Date.UTC(2000, 0, 1, 12, 0, 0))
    readonly property real daysSinceEpoch: (Time.now.getTime() - epochJ2000.getTime()) / dayMs
    readonly property real jd: 2451545.0 + daysSinceEpoch
    readonly property real overlayMargin: 10
    readonly property real detailWidth: Math.min(width * 0.32, 340)
    readonly property real ephemerisWidth: Math.min(width * 0.52, 500)
    readonly property real mapLeftBound: overlayMargin + 8
    readonly property real mapRightBound: Math.max(mapLeftBound + 260, width - detailWidth - overlayMargin * 3)
    readonly property real mapTopBound: 42
    readonly property real mapBottomBound: Math.max(mapTopBound + 220, height - 152)
    readonly property real mapAvailableWidth: Math.max(260, mapRightBound - mapLeftBound)
    readonly property real mapAvailableHeight: Math.max(220, mapBottomBound - mapTopBound)
    readonly property real mapSize: Math.max(220, Math.min(mapAvailableWidth, mapAvailableHeight))
    readonly property real mapCenterX: mapLeftBound + mapAvailableWidth * 0.52
    readonly property real mapCenterY: mapTopBound + mapAvailableHeight * 0.52
    readonly property real yawRad: degToRad(yawDeg)
    readonly property real pitchRad: degToRad(pitchDeg)
    readonly property real cosYaw: Math.cos(yawRad)
    readonly property real sinYaw: Math.sin(yawRad)
    readonly property real cosPitch: Math.cos(pitchRad)
    readonly property real sinPitch: Math.sin(pitchRad)
    readonly property real currentViewScale: mapSize * 0.44 * zoomLevel / 30.2
    readonly property int selectedPlanetId: Math.max(0, Math.min(7, selectedPlanetIndex))
    readonly property var selectedPlanetData: planets[selectedPlanetId]
    readonly property var selectedPlanetState: orbitalState(selectedPlanetData, daysSinceEpoch)
    readonly property var earthState: orbitalState(planets[2], daysSinceEpoch)
    property real yawDeg: -34
    property real pitchDeg: 58
    property real zoomLevel: 1
    property real dragStartYaw: yawDeg
    property real dragStartPitch: pitchDeg
    property real dragPressX: 0
    property real dragPressY: 0
    property real pendingYawDeg: yawDeg
    property real pendingPitchDeg: pitchDeg
    property bool dragActive: false
    property int selectedPlanetIndex: 2
    readonly property int orbitSampleCount: dragActive ? 42 : 96
    property var cachedOrbitPaths: []
    readonly property real minZoomLevel: 0.22
    readonly property real maxZoomLevel: 8.0
    readonly property real centuryDays: 36525
    // Gaussian gravitational constant squared in AU^3/day^2. Used as the solar GM for visual ephemeris mean motion.
    readonly property real gmSun: 2.959122082855911e-4

    Behavior on zoomLevel {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    readonly property var planetColors: [
        "#c8c8c8", "#e8c060", "#48A0FF", "#e04040",
        "#d8a060", "#e0c880", "#70d0d0", "#4060ff"
    ]

    readonly property var zodiacSymbols: [
        "ARI", "TAU", "GEM", "CNC", "LEO", "VIR",
        "LIB", "SCO", "SGR", "CAP", "AQR", "PSC"
    ]

    readonly property var planets: [
        {
            name: "MERCURY", code: "ME", a: 0.38709927, da: 0.00000037, e: 0.20563593, de: 0.00001906, i: 7.00497902, di: -0.00594749,
            node: 48.33076593, dnode: -0.12534081, peri: 77.45779628, dperi: 0.16047689, meanLongitude: 252.25032350, dmeanLongitude: 149472.67411175, size: 5, mag0: -0.6
        }, {
            name: "VENUS", code: "VE", a: 0.72333566, da: 0.00000390, e: 0.00677672, de: -0.00004107, i: 3.39467605, di: -0.00078890,
            node: 76.67984255, dnode: -0.27769418, peri: 131.60246718, dperi: 0.00268329, meanLongitude: 181.97909950, dmeanLongitude: 58517.81538729, size: 7, mag0: -4.4
        }, {
            name: "EARTH", code: "EA", a: 1.00000261, da: 0.00000562, e: 0.01671123, de: -0.00004392, i: -0.00001531, di: -0.01294668,
            node: 0.0, dnode: 0.0, peri: 102.93768193, dperi: 0.32327364, meanLongitude: 100.46457166, dmeanLongitude: 35999.37244981, size: 8, mag0: -3.9
        }, {
            name: "MARS", code: "MA", a: 1.52371034, da: 0.00001847, e: 0.09339410, de: 0.00007882, i: 1.84969142, di: -0.00813131,
            node: 49.55953891, dnode: -0.29257343, peri: 336.04084, dperi: 0.44390166, meanLongitude: 355.44691, dmeanLongitude: 19140.30268499, size: 6, mag0: -1.5
        }, {
            name: "JUPITER", code: "JU", a: 5.20288700, da: -0.00011607, e: 0.04838624, de: -0.00013253, i: 1.30439695, di: -0.00183714,
            node: 100.47390909, dnode: 0.20469106, peri: 14.72847983, dperi: 0.21252668, meanLongitude: 34.39644051, dmeanLongitude: 3034.74612775, size: 13, mag0: -9.4
        }, {
            name: "SATURN", code: "SA", a: 9.53667594, da: -0.00125060, e: 0.05386179, de: -0.00050991, i: 2.48599187, di: 0.00193609,
            node: 113.66242448, dnode: -0.28867794, peri: 92.59887831, dperi: -0.41897216, meanLongitude: 49.95424423, dmeanLongitude: 1222.49362201, size: 12, mag0: -8.9
        }, {
            name: "URANUS", code: "UR", a: 19.18916464, da: -0.00196176, e: 0.04725744, de: -0.00004397, i: 0.77263783, di: -0.00242939,
            node: 74.01692503, dnode: 0.04240589, peri: 170.95427630, dperi: 0.40805281, meanLongitude: 313.23810451, dmeanLongitude: 428.48202785, size: 10, mag0: -7.1
        }, {
            name: "NEPTUNE", code: "NE", a: 30.06992276, da: 0.00026291, e: 0.00859048, de: 0.00005105, i: 1.77004347, di: 0.00035372,
            node: 131.78422574, dnode: -0.00508664, peri: 44.96476227, dperi: -0.32241464, meanLongitude: 304.87997031, dmeanLongitude: 218.45945325, size: 10, mag0: -6.9
        }
    ]

    function clamp(value: real, minimum: real, maximum: real): real {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function wrap360(value: real): real {
        const wrapped = value % 360;
        return wrapped < 0 ? wrapped + 360 : wrapped;
    }

    function degToRad(value: real): real {
        return value * Math.PI / 180;
    }

    function radToDeg(value: real): real {
        return value * 180 / Math.PI;
    }

    function elementValue(p: var, baseName: string, rateName: string, centuries: real): real {
        const base = typeof p[baseName] === "number" ? p[baseName] : 0;
        const rate = typeof p[rateName] === "number" ? p[rateName] : 0;
        return base + rate * centuries;
    }

    function elementsFor(p: var, dayOffset: real): var {
        const centuries = dayOffset / centuryDays;
        const a = Math.max(0.0001, elementValue(p, "a", "da", centuries));
        const e = clamp(elementValue(p, "e", "de", centuries), 0, 0.4);
        const inc = elementValue(p, "i", "di", centuries);
        const node = wrap360(elementValue(p, "node", "dnode", centuries));
        const peri = wrap360(elementValue(p, "peri", "dperi", centuries));
        const meanLongitude = wrap360(elementValue(p, "meanLongitude", "dmeanLongitude", centuries));
        const m0 = wrap360(meanLongitude - peri);
        const n = meanMotion(a);
        return { a, e, i: inc, node, peri, meanLongitude, m0, n, centuries };
    }

    function planetSize(p: var): real { return typeof p.size === "number" && p.size > 0 ? p.size : 7; }

    function meanMotion(a: real): real {
        return Math.sqrt(gmSun / (a * a * a)) * (180 / Math.PI);
    }

    function solveKepler(meanAnomalyDeg: real, e: real): real {
        const m = degToRad(meanAnomalyDeg);
        let E = m + e * Math.sin(m) / (1 - Math.sin(m + e) + Math.sin(m));
        for (let step = 0; step < 20; step++) {
            const dE = (E - e * Math.sin(E) - m) / (1 - e * Math.cos(E));
            E -= dE;
            if (Math.abs(dE) < 1e-12)
                break;
        }
        return E;
    }

    function orbitalState(p: var, dayOffset: real): var {
        const el = elementsFor(p, dayOffset);
        const a = el.a;
        const e = el.e;
        const inc = degToRad(el.i);
        const node = degToRad(el.node);
        const peri = degToRad(el.peri);
        const M = el.m0;
        const E = solveKepler(M, e);
        const cosE = Math.cos(E);
        const sinE = Math.sin(E);
        const xv = a * (cosE - e);
        const yv = a * Math.sqrt(1 - e * e) * sinE;
        const nu = Math.atan2(yv, xv);
        const r = Math.sqrt(xv * xv + yv * yv);

        const arg = nu + peri - node;
        const cosNode = Math.cos(node);
        const sinNode = Math.sin(node);
        const cosArg = Math.cos(arg);
        const sinArg = Math.sin(arg);
        const cosI = Math.cos(inc);
        const sinI = Math.sin(inc);

        const x = r * (cosNode * cosArg - sinNode * sinArg * cosI);
        const y = r * (sinNode * cosArg + cosNode * sinArg * cosI);
        const z = r * (sinArg * sinI);

        const eclLon = wrap360(radToDeg(Math.atan2(y, x)));
        const eclLat = radToDeg(Math.atan2(z, Math.sqrt(x * x + y * y)));

        return {
            x, y, z, r,
            eclLon, eclLat,
            trueAnomaly: wrap360(radToDeg(nu)),
            meanAnomaly: wrap360(M),
            eccentricAnomaly: wrap360(radToDeg(E)),
            elements: el
        };
    }

    function zodiacIndex(eclLon: real): int {
        return Math.floor(wrap360(eclLon) / 30);
    }

    function phaseAngle(planetXYZ: var, earthXYZ: var): real {
        const dx = earthXYZ.x - planetXYZ.x;
        const dy = earthXYZ.y - planetXYZ.y;
        const dz = earthXYZ.z - planetXYZ.z;
        const distEarth = Math.sqrt(dx * dx + dy * dy + dz * dz);
        if (distEarth < 1e-9)
            return 0;
        const dot = -(dx * planetXYZ.x + dy * planetXYZ.y + dz * planetXYZ.z) / (distEarth * planetXYZ.r);
        return radToDeg(Math.acos(clamp(dot, -1, 1)));
    }

    function apparentMagnitude(p: var, rHelio: real, distEarth: real, phaseDeg: real): real {
        const absMag = typeof p.mag0 === "number" ? p.mag0 : -3.9;
        const safeDistance = Math.max(0.0001, distEarth);
        const phaseTerm = Math.max(0, phaseDeg) * 0.013;
        return absMag + 5 * Math.log10(Math.max(0.0001, rHelio * safeDistance)) + phaseTerm;
    }

    function earthDistanceFor(state: var): real {
        return Math.sqrt((state.x - earthState.x) ** 2 + (state.y - earthState.y) ** 2 + (state.z - earthState.z) ** 2);
    }

    function stateFor(p: var): var {
        return orbitalState(p, daysSinceEpoch);
    }

    function selectedState(): var {
        return selectedPlanetState;
    }

    function selectedPlanet(): var {
        return selectedPlanetData;
    }

    function zoomStatusLine(): string {
        if (zoomLevel <= minZoomLevel * 1.08)
            return "ZOOM LIMIT // MINIMUM RANGE";
        if (zoomLevel >= maxZoomLevel * 0.92)
            return "ZOOM LIMIT // MAXIMUM RANGE";
        return "ZOOM RANGE // NOMINAL";
    }

    function projectPointInto(point: var, target: var): void {
        const x1 = point.x * cosYaw - point.y * sinYaw;
        const y1 = point.x * sinYaw + point.y * cosYaw;
        const z1 = point.z;
        const y2 = y1 * cosPitch - z1 * sinPitch;
        const z2 = y1 * sinPitch + z1 * cosPitch;
        const persp = 1 / (1 + z2 * 0.016);
        target.x = mapCenterX + x1 * currentViewScale * persp;
        target.y = mapCenterY + y2 * currentViewScale * persp;
        target.depth = z2;
        target.perspective = persp;
    }

    function planetLineCompact(p: var): string {
        const s = stateFor(p);
        const code = p.code;
        const r = s.r.toFixed(3);
        const d = earthDistanceFor(s).toFixed(3);
        const lon = s.eclLon.toFixed(1);
        const lat = s.eclLat.toFixed(1);
        return code + " r" + r + " d" + d + " λ" + lon + "° β" + lat + "°";
    }

    function planetDetailLine(p: var): string {
        const s = stateFor(p);
        return p.code + " X " + s.x.toFixed(3) + " Y " + s.y.toFixed(3) + " Z " + s.z.toFixed(3) + " AU";
    }

    function buildOrbitPath(p: var, samples: int): var {
        const path = [];
        const el = elementsFor(p, daysSinceEpoch);
        const periodDays = 360 / el.n;
        for (let sample = 0; sample <= samples; sample++)
            path.push(orbitalState(p, daysSinceEpoch + sample * periodDays / samples));
        return path;
    }

    function buildOrbitPaths(): void {
        const paths = [];
        for (let i = 0; i < planets.length; i++)
            paths.push({ high: buildOrbitPath(planets[i], 96), low: buildOrbitPath(planets[i], 42) });
        cachedOrbitPaths = paths;
    }

    function orbitPathFor(index: int): var {
        if (!cachedOrbitPaths || index < 0 || index >= cachedOrbitPaths.length)
            return [];
        return dragActive ? cachedOrbitPaths[index].low : cachedOrbitPaths[index].high;
    }

    function pinLabelX(proj: var, labelW: real): real {
        const pref = proj.depth >= 0 ? proj.x + 14 : proj.x - labelW - 14;
        return Math.min(mapRightBound - labelW - 10, Math.max(mapLeftBound + 4, pref));
    }

    function pinLabelY(proj: var, labelH: real): real {
        return Math.min(mapBottomBound - labelH, Math.max(mapTopBound, proj.y - labelH / 2));
    }

    function requestScenePaint(): void { orbitCanvas.requestPaint(); }

    function scheduleViewUpdate(nextYaw: real, nextPitch: real): void {
        pendingYawDeg = nextYaw;
        pendingPitchDeg = nextPitch;
        if (!viewUpdateTimer.running)
            viewUpdateTimer.start();
    }

    function applyPendingView(): void {
        yawDeg = pendingYawDeg;
        pitchDeg = pendingPitchDeg;
    }

    function resetView(): void {
        yawDeg = -34;
        pitchDeg = 58;
        zoomLevel = 1;
    }

    function setTopDownView(): void {
        yawDeg = 0;
        pitchDeg = 90;
    }

    function setEdgeOnView(): void {
        yawDeg = 0;
        pitchDeg = 0;
    }

    onDaysSinceEpochChanged: requestScenePaint()
    onYawDegChanged: requestScenePaint()
    onPitchDegChanged: requestScenePaint()
    onZoomLevelChanged: requestScenePaint()
    onOrbitSampleCountChanged: requestScenePaint()
    onWidthChanged: requestScenePaint()
    onHeightChanged: requestScenePaint()
    onSelectedPlanetIndexChanged: requestScenePaint()

    Component.onCompleted: buildOrbitPaths()

    Timer {
        id: viewUpdateTimer
        interval: 16
        repeat: false
        onTriggered: root.applyPendingView()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.panel
        border.color: Theme.line
        border.width: Theme.lineWidth
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        color: "transparent"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth
        opacity: 0.35
    }

    ScanlineOverlay {
        anchors.fill: parent
        visible: SettingsService.scanlinesEnabled
        lineOpacity: 0.035 * SettingsService.intensity * SettingsService.scanlineStrength
        z: 100
    }

    Canvas {
        id: orbitCanvas
        anchors.fill: parent
        opacity: 0.98
        z: 0

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            const accent = Theme.line.toString();
            const dim = Theme.border.toString();
            const lineDim = Theme.lineDim.toString();
            const textDim = Theme.textDim.toString();
            const danger = Theme.danger.toString();
            const cx = root.mapCenterX;
            const cy = root.mapCenterY;
            const gridRadius = root.mapSize * 0.46 * root.zoomLevel;
            const scr = { x: 0, y: 0, depth: 0, perspective: 1 };
            const scr2 = { x: 0, y: 0, depth: 0, perspective: 1 };

            ctx.save();
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            ctx.globalAlpha = 0.08;
            ctx.strokeStyle = accent;
            ctx.lineWidth = 0.7;
            for (let ring = 1; ring <= 5; ring++) {
                ctx.beginPath();
                ctx.arc(cx, cy, gridRadius * ring / 5, 0, Math.PI * 2);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.14;
            for (let a = 0; a < 12; a++) {
                const angle = a * Math.PI / 6 - Math.PI / 2;
                const r1 = gridRadius * 0.82;
                const r2 = gridRadius;
                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle) * r1, cy + Math.sin(angle) * r1);
                ctx.lineTo(cx + Math.cos(angle) * r2, cy + Math.sin(angle) * r2);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.28;
            ctx.fillStyle = accent;
            ctx.font = "bold " + Theme.fontTiny + "px " + Theme.fontFamily;
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            for (let z = 0; z < 12; z++) {
                const angle = z * Math.PI / 6 - Math.PI / 2;
                const lr = gridRadius + 16;
                const labelX = root.clamp(cx + Math.cos(angle) * lr, root.mapLeftBound + 16, root.mapRightBound - 16);
                const labelY = root.clamp(cy + Math.sin(angle) * lr, root.mapTopBound + 12, root.mapBottomBound - 12);
                ctx.fillText(root.zodiacSymbols[z], labelX, labelY);
            }

            ctx.globalAlpha = 0.26;
            ctx.strokeStyle = textDim;
            ctx.lineWidth = 0.8;
            ctx.beginPath();
            ctx.moveTo(cx - gridRadius * 1.06, cy);
            ctx.lineTo(cx + gridRadius * 1.06, cy);
            ctx.moveTo(cx, cy - gridRadius * 1.06);
            ctx.lineTo(cx, cy + gridRadius * 1.06);
            ctx.stroke();

            ctx.globalAlpha = 0.3;
            ctx.fillStyle = accent;
            ctx.font = Theme.fontTiny + "px " + Theme.fontFamily;
            ctx.textAlign = "left";
            ctx.fillText("+X ♈", Math.min(root.mapRightBound - 42, cx + gridRadius * 1.06 + 4), cy + 1);
            ctx.fillText("+Y", cx - 4, Math.max(root.mapTopBound + 8, cy - gridRadius * 1.06 - 8));

            for (let p = 0; p < root.planets.length; p++) {
                const path = root.orbitPathFor(p);
                const color = root.planetColors[p];
                ctx.beginPath();
                for (let s = 0; s < path.length; s++) {
                    root.projectPointInto(path[s], scr);
                    if (s === 0)
                        ctx.moveTo(scr.x, scr.y);
                    else
                        ctx.lineTo(scr.x, scr.y);
                }

                const selectedOrbit = p === root.selectedPlanetIndex;
                const majorOrbit = p === 2 || p >= 4;
                const baseWidth = selectedOrbit ? 3.4 : (majorOrbit ? 2.6 : 2.1);
                ctx.globalAlpha = selectedOrbit ? 0.28 : 0.16;
                ctx.strokeStyle = color;
                ctx.lineWidth = baseWidth + 2.2;
                ctx.stroke();

                ctx.globalAlpha = selectedOrbit ? 0.72 : (0.40 + p * 0.025);
                ctx.strokeStyle = color;
                ctx.lineWidth = baseWidth;
                ctx.stroke();

                ctx.globalAlpha = selectedOrbit ? 0.34 : 0.12;
                ctx.strokeStyle = Theme.text.toString();
                ctx.lineWidth = Math.max(0.7, baseWidth * 0.34);
                ctx.stroke();
            }

            for (let p = root.planets.length - 1; p >= 0; p--) {
                const planet = root.planets[p];
                const s = root.stateFor(planet);
                const color = root.planetColors[p];

                for (let trail = 28; trail >= 0; trail--) {
                    const tState = root.orbitalState(planet, root.daysSinceEpoch - (trail + 1) * 1.2);
                    root.projectPointInto(tState, scr2);
                    const alpha = 0.18 - trail * 0.006;
                    if (alpha <= 0)
                        continue;
                    ctx.globalAlpha = alpha;
                    ctx.fillStyle = color;
                    ctx.beginPath();
                    ctx.arc(scr2.x, scr2.y, 2.2, 0, Math.PI * 2);
                    ctx.fill();
                }

                root.projectPointInto(s, scr);
                const nodeSize = root.planetSize(planet) * Math.max(0.72, Math.min(1.28, scr.perspective));
                const isSelected = p === root.selectedPlanetIndex;

                if (isSelected) {
                    const pulse = 0.5 + 0.5 * Math.sin(Date.now() / 520);
                    ctx.globalAlpha = 0.20 + (scr.depth >= 0 ? 0.12 : 0.04) + 0.14 * pulse;
                    ctx.strokeStyle = accent;
                    ctx.lineWidth = 1.2;
                    ctx.setLineDash([6, 3]);
                    ctx.beginPath();
                    ctx.arc(scr.x, scr.y, nodeSize + 22, 0, Math.PI * 2);
                    ctx.stroke();
                    ctx.setLineDash([]);

                    ctx.globalAlpha = 0.18 + 0.12 * pulse;
                    ctx.beginPath();
                    ctx.arc(scr.x, scr.y, nodeSize + 30, Math.PI * 0.12, Math.PI * 0.46);
                    ctx.arc(scr.x, scr.y, nodeSize + 30, Math.PI * 1.12, Math.PI * 1.46);
                    ctx.stroke();

                    ctx.globalAlpha = 0.35;
                    for (let r = 0; r < 4; r++) {
                        ctx.beginPath();
                        ctx.moveTo(scr.x, scr.y + nodeSize + 16 + r * 4);
                        ctx.lineTo(scr.x, scr.y + nodeSize + 28 + r * 4);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(scr.x + nodeSize + 16 + r * 4, scr.y);
                        ctx.lineTo(scr.x + nodeSize + 28 + r * 4, scr.y);
                        ctx.stroke();
                    }
                }

                ctx.globalAlpha = 0.16 + Math.max(0, scr.depth) * 0.006;
                ctx.strokeStyle = isSelected ? accent : color;
                ctx.lineWidth = Theme.lineWidth;
                ctx.beginPath();
                ctx.arc(scr.x, scr.y, (nodeSize + 10) / 2, 0, Math.PI * 2);
                ctx.stroke();

                ctx.globalAlpha = scr.depth >= 0 ? 0.96 : 0.54;
                ctx.fillStyle = planet.code === "EA" ? Theme.text.toString() : color;
                ctx.beginPath();
                ctx.arc(scr.x, scr.y, nodeSize / 2, 0, Math.PI * 2);
                ctx.fill();

                if (planet.code !== "ME" && planet.code !== "VE") {
                    ctx.globalAlpha = 0.06 + Math.max(0, scr.depth) * 0.002;
                    const glowGrad = ctx.createRadialGradient(scr.x, scr.y, nodeSize * 0.3, scr.x, scr.y, nodeSize * 1.6);
                    glowGrad.addColorStop(0, color);
                    glowGrad.addColorStop(1, "transparent");
                    ctx.fillStyle = glowGrad;
                    ctx.beginPath();
                    ctx.arc(scr.x, scr.y, nodeSize * 1.6, 0, Math.PI * 2);
                    ctx.fill();
                }

                ctx.globalAlpha = 0.28;
                ctx.strokeStyle = accent;
                ctx.lineWidth = 1.5;
                const crossSize = isSelected ? 16 : 12;
                ctx.beginPath();
                ctx.moveTo(scr.x, scr.y - crossSize);
                ctx.lineTo(scr.x, scr.y + crossSize);
                ctx.moveTo(scr.x - crossSize, scr.y);
                ctx.lineTo(scr.x + crossSize, scr.y);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.38;
            ctx.strokeStyle = accent;
            ctx.lineWidth = 2.2;
            ctx.beginPath();
            ctx.arc(cx, cy, 22, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(cx - 38, cy);
            ctx.lineTo(cx + 38, cy);
            ctx.moveTo(cx, cy - 38);
            ctx.lineTo(cx, cy + 38);
            ctx.stroke();

            ctx.globalAlpha = 0.15;
            ctx.fillStyle = danger;
            ctx.beginPath();
            ctx.arc(cx, cy, 9, 0, Math.PI * 2);
            ctx.fill();

            ctx.globalAlpha = 0.36;
            ctx.fillStyle = accent;
            ctx.font = Theme.fontTiny + "px " + Theme.fontFamily;
            ctx.textAlign = "left";
            ctx.fillText("HELIOCENTRIC ECLIPTIC  J2000.0  AU", 18, height - 26);
            ctx.textAlign = "right";
            ctx.fillText("YAW " + Math.round(root.yawDeg) + "  PITCH " + Math.round(root.pitchDeg) + "  ZOOM " + root.zoomLevel.toFixed(2) + "X", width - 18, height - 26);
            ctx.textAlign = "left";

            ctx.restore();
        }
    }

    MouseArea {
        id: viewDragArea
        anchors.fill: parent
        anchors.topMargin: 38
        anchors.bottomMargin: 52
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        preventStealing: true
        propagateComposedEvents: false
        onPressed: mouse => {
            if (mouse.button === Qt.RightButton)
                return;
            dragActive = true;
            dragStartYaw = yawDeg;
            dragStartPitch = pitchDeg;
            pendingYawDeg = yawDeg;
            pendingPitchDeg = pitchDeg;
            dragPressX = mouse.x;
            dragPressY = mouse.y;
            mouse.accepted = true;
        }
        onPositionChanged: mouse => {
            if (!pressed)
                return;
            scheduleViewUpdate(dragStartYaw + (mouse.x - dragPressX) * 0.35, clamp(dragStartPitch + (mouse.y - dragPressY) * 0.22, 18, 78));
            mouse.accepted = true;
        }
        onReleased: mouse => {
            dragActive = false;
            applyPendingView();
            mouse.accepted = true;
        }
        onCanceled: {
            dragActive = false;
            applyPendingView();
        }
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                const mx = mouse.x;
                const my = mouse.y;
                let bestDist = 640;
                let bestIdx = root.selectedPlanetIndex;
                for (let p = 0; p < root.planets.length; p++) {
                    const s = root.stateFor(root.planets[p]);
                    const proj = { x: 0, y: 0, depth: 0, perspective: 1 };
                    root.projectPointInto(s, proj);
                    const dist = Math.sqrt((proj.x - mx) * (proj.x - mx) + (proj.y - my) * (proj.y - my));
                    if (dist < bestDist) {
                        bestDist = dist;
                        bestIdx = p;
                    }
                }
                if (bestDist < 50)
                    root.selectedPlanetIndex = bestIdx;
            }
            mouse.accepted = true;
        }
    }

    WheelHandler {
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const step = event.angleDelta.y > 0 ? 1.16 : 0.86;
            root.zoomLevel = root.clamp(root.zoomLevel * step, root.minZoomLevel, root.maxZoomLevel);
        }
    }

    Repeater {
        model: root.planets

        Item {
            required property int index
            required property var modelData
            readonly property var s: root.stateFor(modelData)

            function pointScratch(): var {
                const p = { x: 0, y: 0, depth: 0, perspective: 1 };
                root.projectPointInto(s, p);
                return p;
            }

            readonly property var proj: pointScratch()

            TacticalLabel {
                id: labelProbe
                visible: modelData.code !== root.planets[root.selectedPlanetIndex].code
                text: modelData.code + " " + root.planetDetailLine(modelData)
                size: Theme.fontTiny
            }

            Rectangle {
                x: proj.depth >= 0 ? proj.x + 6 : root.pinLabelX(proj, labelProbe.implicitWidth) + labelProbe.implicitWidth
                y: proj.y
                width: Math.max(6, Math.abs(root.pinLabelX(proj, labelProbe.implicitWidth) - proj.x) - 8)
                height: Theme.lineWidth
                color: root.planetColors[index]
                opacity: 0.32
            }

            TacticalLabel {
                x: root.pinLabelX(proj, implicitWidth)
                y: root.pinLabelY(proj, implicitHeight)
                text: labelProbe.text
                accent: proj.depth >= 0
                dim: proj.depth < 0
                size: Theme.fontTiny
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: root.ephemerisWidth
        height: Math.min(parent.height * 0.38, ephemerisColumn.implicitHeight + 18)
        color: "#1a000000"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth

        ColumnLayout {
            id: ephemerisColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2

            TacticalLabel {
                Layout.fillWidth: true
                text: "APPROX EPHEMERIS  J2000 KEPLER  HELIOCENTRIC AU  //  JD " + root.jd.toFixed(1)
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            Repeater {
                model: root.planets

                Rectangle {
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    color: index === root.selectedPlanetIndex ? Theme.lineDim : (ephemerisArea.containsMouse || activeFocus ? Theme.panelSoft : "transparent")
                    border.color: index === root.selectedPlanetIndex || ephemerisArea.containsMouse || activeFocus ? root.planetColors[index] : "transparent"
                    border.width: Theme.lineWidth
                    activeFocusOnTab: true
                    Keys.onReturnPressed: root.selectedPlanetIndex = index
                    Keys.onEnterPressed: root.selectedPlanetIndex = index
                    Keys.onSpacePressed: root.selectedPlanetIndex = index

                    MouseArea {
                        id: ephemerisArea

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.selectedPlanetIndex = parent.index
                        onEntered: TooltipService.show("SELECT " + parent.modelData.name, "Target " + parent.modelData.name + " in the orbital detail pane and map reticle.", "orbit-row-" + parent.modelData.code)
                        onExited: TooltipService.clear("orbit-row-" + parent.modelData.code)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8
                            radius: 4
                            color: root.planetColors[index]
                        }

                        TacticalLabel {
                            text: modelData.code
                            accent: index === root.selectedPlanetIndex
                            size: Theme.fontTiny
                        }

                        TacticalLabel {
                            Layout.fillWidth: true
                            text: root.planetLineCompact(modelData)
                            dim: index !== root.selectedPlanetIndex
                            accent: index === root.selectedPlanetIndex
                            size: Theme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: detailPanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.topMargin: 42
        anchors.bottomMargin: 140
        width: root.detailWidth
        color: "#1a000000"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            TacticalLabel {
                Layout.fillWidth: true
                text: "TARGET ACQUIRED  //  " + root.selectedPlanet().name.toUpperCase()
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            Item { Layout.preferredHeight: 2 }

            TacticalLabel {
                Layout.fillWidth: true
                text: "ORBITAL ELEMENTS  J2000"
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            Repeater {
                model: {
                    const s = root.selectedState();
                    const el = s.elements;
                    return [
                        ["a", el.a.toFixed(6) + " AU"],
                        ["e", el.e.toFixed(6)],
                        ["i", el.i.toFixed(4) + "\u00b0"],
                        ["\u03a9", el.node.toFixed(4) + "\u00b0"],
                        ["\u03d6", el.peri.toFixed(4) + "\u00b0"],
                        ["L", el.meanLongitude.toFixed(4) + "\u00b0"],
                        ["M", el.m0.toFixed(4) + "\u00b0"]
                    ]
                }

                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 4

                    TacticalLabel {
                        Layout.preferredWidth: 26
                        text: modelData[0]
                        accent: true
                        size: Theme.fontTiny
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: modelData[1]
                        dim: true
                        size: Theme.fontTiny
                        elide: Text.ElideRight
                    }
                }
            }

            Item { Layout.preferredHeight: 2 }

            TacticalLabel {
                Layout.fillWidth: true
                text: "CURRENT STATE  " + Qt.formatDateTime(Time.now, "hh:mm:ss")
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            Repeater {
                model: {
                    const p = root.selectedPlanet();
                    const s = root.selectedState();
                    const el = s.elements;
                    const distEarth = Math.sqrt((s.x - root.earthState.x) ** 2 + (s.y - root.earthState.y) ** 2 + (s.z - root.earthState.z) ** 2);
                    const phase = root.phaseAngle(s, root.earthState);
                    const mag = root.apparentMagnitude(p, s.r, distEarth, phase);
                    const zIdx = root.zodiacIndex(s.eclLon);
                    return [
                        ["JD", root.jd.toFixed(4)],
                        ["r", s.r.toFixed(4) + " AU (heliocentric)"],
                        ["dist", distEarth.toFixed(4) + " AU (from Earth)"],
                        ["\u03bd", s.trueAnomaly.toFixed(2) + "\u00b0 (true anomaly)"],
                        ["E", s.eccentricAnomaly.toFixed(2) + "\u00b0 (ecc anomaly)"],
                        ["\u03bb", s.eclLon.toFixed(3) + "\u00b0 (ecliptic lon)"],
                        ["\u03b2", s.eclLat.toFixed(4) + "\u00b0 (ecliptic lat)"],
                        ["n", el.n.toFixed(6) + "\u00b0/day"],
                        ["phase", phase.toFixed(1) + "\u00b0"],
                        ["mag", mag.toFixed(2) + " (apparent)"],
                        ["const", root.zodiacSymbols[zIdx]]
                    ]
                }

                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 4

                    TacticalLabel {
                        Layout.preferredWidth: 34
                        text: modelData[0]
                        accent: true
                        size: Theme.fontTiny
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: modelData[1]
                        dim: true
                        size: Theme.fontTiny
                        elide: Text.ElideRight
                    }
                }
            }

            Item { Layout.fillHeight: true }

            TacticalLabel {
                Layout.fillWidth: true
                text: "VIEWPORT"
                accent: true
                size: Theme.fontTiny
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "YAW " + Math.round(root.yawDeg) + "  PITCH " + Math.round(root.pitchDeg) + "  ZOOM " + root.zoomLevel.toFixed(2)
                dim: true
                size: Theme.fontTiny
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "ZOOM BOUNDS // " + root.minZoomLevel.toFixed(2) + "X - " + root.maxZoomLevel.toFixed(1) + "X"
                dim: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: root.zoomStatusLine()
                accent: root.zoomLevel <= root.minZoomLevel * 1.08 || root.zoomLevel >= root.maxZoomLevel * 0.92
                dim: root.zoomLevel > root.minZoomLevel * 1.08 && root.zoomLevel < root.maxZoomLevel * 0.92
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "SOURCE // J2000 mean elements + secular rates // GM " + root.gmSun.toExponential(3) + " AU^3/D^2"
                dim: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "PRECISION // VISUAL EPHEMERIS, NOT NAVIGATION-GRADE"
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { label: "RESET", color: Theme.line, tooltip: "Restore the default oblique orbital camera and zoom.", action: function() { root.resetView(); } },
                        { label: "TOP", color: Theme.lineDim, tooltip: "Switch to an overhead ecliptic view for longitude/track inspection.", action: function() { root.setTopDownView(); } },
                        { label: "EDGE", color: Theme.lineDim, tooltip: "Switch to edge-on view to inspect inclination and vertical separation.", action: function() { root.setEdgeOnView(); } }
                    ]

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityControlHeight
                        color: btnArea.containsMouse || activeFocus ? Theme.lineDim : "transparent"
                        border.color: activeFocus ? Theme.line : modelData.color
                        border.width: Theme.lineWidth
                        activeFocusOnTab: true
                        Keys.onReturnPressed: modelData.action()
                        Keys.onEnterPressed: modelData.action()
                        Keys.onSpacePressed: modelData.action()

                        MouseArea {
                            id: btnArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: parent.modelData.action()
                            onEntered: TooltipService.show("ORBIT VIEW " + parent.modelData.label, parent.modelData.tooltip, "orbit-view-" + parent.modelData.label)
                            onExited: TooltipService.clear("orbit-view-" + parent.modelData.label)
                        }

                        TacticalLabel {
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            accent: btnArea.containsMouse || parent.activeFocus
                            size: Theme.fontTiny
                        }
                    }
                }
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "RIGHT-CLICK PLANET TO SELECT"
                dim: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 30
        height: 30
        radius: 15
        color: Theme.line
        opacity: 0.10
    }

    Rectangle {
        anchors.centerIn: parent
        width: 10
        height: 10
        radius: 5
        color: Theme.line
    }

    Item {
        anchors.fill: parent

        Repeater {
            model: [
                { left: true, top: true },
                { left: false, top: true },
                { left: true, top: false },
                { left: false, top: false }
            ]

            Item {
                required property var modelData
                readonly property bool leftSide: modelData.left
                readonly property bool topSide: modelData.top
                x: leftSide ? 0 : parent.width - width
                y: topSide ? 0 : parent.height - height
                width: 82
                height: 82

                Rectangle {
                    x: parent.leftSide ? 0 : parent.width - width
                    y: parent.topSide ? 0 : parent.height - height
                    width: parent.width
                    height: Theme.lineWidth
                    color: Theme.line
                }

                Rectangle {
                    x: parent.leftSide ? 0 : parent.width - width
                    y: parent.topSide ? 0 : parent.height - height
                    width: Theme.lineWidth
                    height: parent.height
                    color: Theme.line
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Theme.panelPadding
        anchors.topMargin: 7
        width: Math.min(parent.width - 116, statusText.implicitWidth + 18)
        height: 28
        color: "transparent"

        TacticalLabel {
            id: statusText
            anchors.centerIn: parent
            text: "ORBIT SENSOR  //  UTC " + Qt.formatDateTime(Time.now, "yyyy-MM-dd hh:mm:ss") + "  //  JD " + root.jd.toFixed(1) + "  //  J2000+" + Math.floor(root.daysSinceEpoch) + "D  //  KEPLER APPROX"
            accent: true
            size: Theme.fontTiny
            elide: Text.ElideRight
        }
    }

    PanelCloseButton {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Theme.panelPadding
        anchors.topMargin: 8
        onCloseRequested: ExpansionService.close()
    }

    TacticalLabel {
        anchors.right: parent.right
        anchors.rightMargin: Theme.panelPadding + 96
        anchors.top: parent.top
        anchors.topMargin: 7
        text: "[ACTIVE]"
        accent: true
        size: Theme.fontTiny
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: Theme.panelPadding + 64
        anchors.top: parent.top
        anchors.topMargin: 4
        width: 24
        height: 18
        color: "transparent"
        border.color: activeFocus ? Theme.line : Theme.lineDim
        border.width: Theme.lineWidth
        activeFocusOnTab: selectedPlanetIndex > 0
        Keys.onReturnPressed: root.selectedPlanetIndex = Math.max(0, root.selectedPlanetIndex - 1)
        Keys.onEnterPressed: root.selectedPlanetIndex = Math.max(0, root.selectedPlanetIndex - 1)
        Keys.onSpacePressed: root.selectedPlanetIndex = Math.max(0, root.selectedPlanetIndex - 1)

        TacticalLabel {
            anchors.centerIn: parent
            text: "<"
            accent: selectedPlanetIndex > 0
            dim: selectedPlanetIndex === 0
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: selectedPlanetIndex > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            onClicked: {
                if (selectedPlanetIndex > 0)
                    root.selectedPlanetIndex = Math.max(0, root.selectedPlanetIndex - 1);
            }
            onEntered: TooltipService.show("PREVIOUS PLANET", "Step the orbital detail target backward. Current target: " + root.selectedPlanet().name + ".", "orbit-prev")
            onExited: TooltipService.clear("orbit-prev")
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: Theme.panelPadding + 36
        anchors.top: parent.top
        anchors.topMargin: 4
        width: 24
        height: 18
        color: "transparent"
        border.color: activeFocus ? Theme.line : Theme.lineDim
        border.width: Theme.lineWidth
        activeFocusOnTab: selectedPlanetIndex < 7
        Keys.onReturnPressed: root.selectedPlanetIndex = Math.min(7, root.selectedPlanetIndex + 1)
        Keys.onEnterPressed: root.selectedPlanetIndex = Math.min(7, root.selectedPlanetIndex + 1)
        Keys.onSpacePressed: root.selectedPlanetIndex = Math.min(7, root.selectedPlanetIndex + 1)

        TacticalLabel {
            anchors.centerIn: parent
            text: ">"
            accent: selectedPlanetIndex < 7
            dim: selectedPlanetIndex === 7
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: selectedPlanetIndex < 7 ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            onClicked: {
                if (selectedPlanetIndex < 7)
                    root.selectedPlanetIndex = Math.min(7, root.selectedPlanetIndex + 1);
            }
            onEntered: TooltipService.show("NEXT PLANET", "Step the orbital detail target forward. Current target: " + root.selectedPlanet().name + ".", "orbit-next")
            onExited: TooltipService.clear("orbit-next")
        }
    }
}
