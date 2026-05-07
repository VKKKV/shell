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
    readonly property real mapSize: Math.max(220, Math.min(width - 230, height - 96))
    readonly property real mapCenterX: width * 0.46
    readonly property real mapCenterY: height * 0.52
    readonly property real yawRad: degToRad(yawDeg)
    readonly property real pitchRad: degToRad(pitchDeg)
    readonly property real cosYaw: Math.cos(yawRad)
    readonly property real sinYaw: Math.sin(yawRad)
    readonly property real cosPitch: Math.cos(pitchRad)
    readonly property real sinPitch: Math.sin(pitchRad)
    readonly property real currentViewScale: mapSize * 0.44 * zoomLevel / 30.2
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
    readonly property real minZoomLevel: 0.42
    readonly property real maxZoomLevel: 4.2
    readonly property real gmSun: 2.959122082855911e-4

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
            name: "MERCURY", code: "ME", a: 0.387099, e: 0.205630, i: 7.00487,
            node: 48.33167, peri: 77.45612, meanLongitude: 252.25084, size: 5
        }, {
            name: "VENUS", code: "VE", a: 0.723336, e: 0.006773, i: 3.39471,
            node: 76.68069, peri: 131.60247, meanLongitude: 181.97973, size: 7
        }, {
            name: "EARTH", code: "EA", a: 1.000002, e: 0.016711, i: 0.00005,
            node: 0.0, peri: 102.93768, meanLongitude: 100.46435, size: 8
        }, {
            name: "MARS", code: "MA", a: 1.523710, e: 0.093394, i: 1.84969,
            node: 49.55809, peri: 336.05957, meanLongitude: 355.47252, size: 6
        }, {
            name: "JUPITER", code: "JU", a: 5.202887, e: 0.048386, i: 1.30440,
            node: 100.47391, peri: 14.33178, meanLongitude: 34.33480, size: 13
        }, {
            name: "SATURN", code: "SA", a: 9.536676, e: 0.053862, i: 2.48599,
            node: 113.66242, peri: 93.05727, meanLongitude: 49.94415, size: 12
        }, {
            name: "URANUS", code: "UR", a: 19.18916, e: 0.047257, i: 0.77264,
            node: 74.01693, peri: 173.00529, meanLongitude: 313.23218, size: 10
        }, {
            name: "NEPTUNE", code: "NE", a: 30.06992, e: 0.008590, i: 1.76817,
            node: 131.78421, peri: 48.12369, meanLongitude: 304.88003, size: 10
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

    function planetA(p: var): real { return typeof p.a === "number" && p.a > 0 ? p.a : 1; }
    function planetE(p: var): real { return clamp(typeof p.e === "number" ? p.e : 0, 0, 0.4); }
    function planetI(p: var): real { return typeof p.i === "number" ? p.i : 0; }
    function planetNode(p: var): real { return typeof p.node === "number" ? p.node : 0; }
    function planetPeri(p: var): real { return typeof p.peri === "number" ? p.peri : 0; }
    function planetMeanLongitude(p: var): real { return typeof p.meanLongitude === "number" ? p.meanLongitude : 0; }
    function planetSize(p: var): real { return typeof p.size === "number" && p.size > 0 ? p.size : 7; }

    function meanMotion(a: real): real {
        return Math.sqrt(gmSun / (a * a * a)) * (180 / Math.PI);
    }

    function meanAnomaly(p: var, dayOffset: real): real {
        const n = meanMotion(planetA(p));
        const m0 = planetMeanLongitude(p) - planetPeri(p);
        return wrap360(m0 + n * dayOffset);
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
        const a = planetA(p);
        const e = planetE(p);
        const inc = degToRad(planetI(p));
        const node = degToRad(planetNode(p));
        const peri = degToRad(planetPeri(p));
        const M = meanAnomaly(p, dayOffset);
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
            eccentricAnomaly: wrap360(radToDeg(E))
        };
    }

    function zodiacIndex(eclLon: real): int {
        return Math.floor(wrap360(eclLon) / 30);
    }

    function phaseAngle(planetXYZ: var, earthXYZ: var): real {
        const dx = planetXYZ.x - earthXYZ.x;
        const dy = planetXYZ.y - earthXYZ.y;
        const dz = planetXYZ.z - earthXYZ.z;
        const distEarth = Math.sqrt(dx * dx + dy * dy + dz * dz);
        if (distEarth < 1e-9)
            return 0;
        const dot = -(dx * planetXYZ.x + dy * planetXYZ.y + dz * planetXYZ.z) / (distEarth * planetXYZ.r);
        return radToDeg(Math.acos(clamp(dot, -1, 1)));
    }

    function apparentMagnitude(p: var, rHelio: real, distEarth: real, phaseDeg: real): real {
        const absMag = p.code === "ME" ? -0.6 : (p.code === "VE" ? -4.4 : (p.code === "MA" ? -1.5 : (p.code === "JU" ? -9.4 : (p.code === "SA" ? -8.9 : (p.code === "UR" ? -7.1 : (p.code === "NE" ? -6.9 : -3.9))))));
        const phaseRad = degToRad(phaseDeg);
        const phaseTerm = phaseDeg < 90 ? 0.013 * phaseDeg : 0.013 * (180 - phaseDeg);
        return absMag + 5 * Math.log10(rHelio * distEarth) + phaseTerm;
    }

    function stateFor(p: var): var {
        return orbitalState(p, daysSinceEpoch);
    }

    function selectedState(): var {
        return stateFor(planets[Math.max(0, Math.min(7, selectedPlanetIndex))]);
    }

    function selectedPlanet(): var {
        return planets[Math.max(0, Math.min(7, selectedPlanetIndex))];
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
        const lon = s.eclLon.toFixed(1);
        const lat = s.eclLat.toFixed(1);
        return code + " r" + r + " λ" + lon + "° β" + lat + "°";
    }

    function planetDetailLine(p: var): string {
        const s = stateFor(p);
        return p.code + " X " + s.x.toFixed(3) + " Y " + s.y.toFixed(3) + " Z " + s.z.toFixed(3) + " AU";
    }

    function buildOrbitPath(p: var, samples: int): var {
        const path = [];
        const periodDays = 2 * Math.PI / (meanMotion(planetA(p)) * Math.PI / 180);
        for (let sample = 0; sample <= samples; sample++)
            path.push(orbitalState(p, sample * periodDays / samples));
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
        return Math.min(width - labelW - 10, Math.max(10, pref));
    }

    function pinLabelY(proj: var, labelH: real): real {
        return Math.min(height - labelH - 72, Math.max(42, proj.y - labelH / 2));
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
                ctx.fillText(root.zodiacSymbols[z], cx + Math.cos(angle) * lr, cy + Math.sin(angle) * lr);
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
            ctx.fillText("+X ♈", cx + gridRadius * 1.06 + 4, cy + 1);
            ctx.fillText("+Y", cx - 4, cy - gridRadius * 1.06 - 8);

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
                ctx.globalAlpha = 0.16 + p * 0.03;
                ctx.strokeStyle = color;
                ctx.lineWidth = p === 2 ? 1.8 : 0.8;
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
                    ctx.globalAlpha = 0.22 + (scr.depth >= 0 ? 0.12 : 0.04) + 0.1 * Math.sin(Date.now() / 600);
                    ctx.strokeStyle = accent;
                    ctx.lineWidth = 1.2;
                    ctx.setLineDash([6, 3]);
                    ctx.beginPath();
                    ctx.arc(scr.x, scr.y, nodeSize + 22, 0, Math.PI * 2);
                    ctx.stroke();
                    ctx.setLineDash([]);

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
        width: Math.min(parent.width * 0.52, 500)
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

                RowLayout {
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
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

    Rectangle {
        id: detailPanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.topMargin: 42
        anchors.bottomMargin: 140
        width: Math.min(parent.width * 0.28, 280)
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
                    const p = root.selectedPlanet();
                    const m0 = p.meanLongitude - p.peri;
                    return [
                        ["a", p.a.toFixed(6) + " AU"],
                        ["e", p.e.toFixed(6)],
                        ["i", p.i.toFixed(4) + "\u00b0"],
                        ["\u03a9", p.node.toFixed(4) + "\u00b0"],
                        ["\u03d6", p.peri.toFixed(4) + "\u00b0"],
                        ["L\u2080", p.meanLongitude.toFixed(4) + "\u00b0"],
                        ["M\u2080", wrap360(m0).toFixed(4) + "\u00b0"]
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
                    const earthState = root.orbitalState(root.planets[2], root.daysSinceEpoch);
                    const distEarth = Math.sqrt((s.x - earthState.x) ** 2 + (s.y - earthState.y) ** 2 + (s.z - earthState.z) ** 2);
                    const phase = root.phaseAngle(s, earthState);
                    const mag = root.apparentMagnitude(p, s.r, distEarth, phase);
                    const zIdx = root.zodiacIndex(s.eclLon);
                    return [
                        ["r", s.r.toFixed(4) + " AU (heliocentric)"],
                        ["dist", distEarth.toFixed(4) + " AU (from Earth)"],
                        ["\u03bd", s.trueAnomaly.toFixed(2) + "\u00b0 (true anomaly)"],
                        ["\u03bb", s.eclLon.toFixed(3) + "\u00b0 (ecliptic lon)"],
                        ["\u03b2", s.eclLat.toFixed(4) + "\u00b0 (ecliptic lat)"],
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { label: "RESET", color: Theme.line, action: function() { root.resetView(); } },
                        { label: "TOP", color: Theme.lineDim, action: function() { root.setTopDownView(); } },
                        { label: "EDGE", color: Theme.lineDim, action: function() { root.setEdgeOnView(); } }
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
            enabled: selectedPlanetIndex > 0
            onClicked: root.selectedPlanetIndex = Math.max(0, root.selectedPlanetIndex - 1)
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
            enabled: selectedPlanetIndex < 7
            onClicked: root.selectedPlanetIndex = Math.min(7, root.selectedPlanetIndex + 1)
        }
    }
}
