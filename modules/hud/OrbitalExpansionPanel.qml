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
    readonly property real coreSize: Math.min(width, height)
    readonly property real mapSize: Math.max(220, Math.min(width - 260, height - 96))
    readonly property real mapCenterX: width * 0.5
    readonly property real mapCenterY: height * 0.52
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
    readonly property int orbitSampleCount: dragActive ? 42 : 96
    readonly property real minZoomLevel: 0.42
    readonly property real maxZoomLevel: 4.2
    readonly property var planets: [
        { name: "MERCURY", code: "ME", a: 0.387099, e: 0.20564, i: 7.005, node: 48.331, peri: 77.457, meanLongitude: 252.251, period: 87.969, size: 5 },
        { name: "VENUS", code: "VE", a: 0.723332, e: 0.00678, i: 3.395, node: 76.680, peri: 131.602, meanLongitude: 181.979, period: 224.701, size: 7 },
        { name: "EARTH", code: "EA", a: 1.000000, e: 0.01671, i: 0.000, node: 0.000, peri: 102.937, meanLongitude: 100.464, period: 365.256, size: 8 },
        { name: "MARS", code: "MA", a: 1.523679, e: 0.09340, i: 1.850, node: 49.558, peri: 336.041, meanLongitude: 355.453, period: 686.980, size: 6 },
        { name: "JUPITER", code: "JU", a: 5.202600, e: 0.04849, i: 1.303, node: 100.464, peri: 14.331, meanLongitude: 34.404, period: 4332.589, size: 13 },
        { name: "SATURN", code: "SA", a: 9.554900, e: 0.05551, i: 2.489, node: 113.665, peri: 93.057, meanLongitude: 49.944, period: 10759.220, size: 12 },
        { name: "URANUS", code: "UR", a: 19.218400, e: 0.04630, i: 0.773, node: 74.006, peri: 173.005, meanLongitude: 313.232, period: 30685.400, size: 10 },
        { name: "NEPTUNE", code: "NE", a: 30.110400, e: 0.00946, i: 1.770, node: 131.784, peri: 48.124, meanLongitude: 304.880, period: 60189.000, size: 10 }
    ]

    function clamp(value: real, minimum: real, maximum: real): real {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function positiveDegrees(value: real): real {
        const wrapped = value % 360;
        return wrapped < 0 ? wrapped + 360 : wrapped;
    }

    function degToRad(value: real): real {
        return value * Math.PI / 180;
    }

    function planetName(planet: var): string {
        return typeof planet.name === "string" && planet.name.length > 0 ? planet.name : "UNKNOWN";
    }

    function planetCode(planet: var): string {
        return typeof planet.code === "string" && planet.code.length > 0 ? planet.code : planetName(planet).slice(0, 2).toUpperCase();
    }

    function planetA(planet: var): real {
        return typeof planet.a === "number" && planet.a > 0 ? planet.a : 1;
    }

    function planetE(planet: var): real {
        return clamp(typeof planet.e === "number" ? planet.e : 0, 0, 0.4);
    }

    function planetI(planet: var): real {
        return typeof planet.i === "number" ? planet.i : 0;
    }

    function planetNode(planet: var): real {
        return typeof planet.node === "number" ? planet.node : 0;
    }

    function planetPeri(planet: var): real {
        return typeof planet.peri === "number" ? planet.peri : 0;
    }

    function planetMeanLongitude(planet: var): real {
        return typeof planet.meanLongitude === "number" ? planet.meanLongitude : 0;
    }

    function planetPeriod(planet: var): real {
        return typeof planet.period === "number" && planet.period > 0 ? planet.period : 365.256;
    }

    function planetSize(planet: var): real {
        return typeof planet.size === "number" && planet.size > 0 ? planet.size : 7;
    }

    function meanAnomaly(planet: var, dayOffset: real): real {
        const base = planetMeanLongitude(planet) - planetPeri(planet);
        return positiveDegrees(base + dayOffset * 360 / planetPeriod(planet));
    }

    function solveKepler(meanAnomalyDeg: real, eccentricity: real): real {
        const mean = degToRad(meanAnomalyDeg);
        let eccentric = mean;
        for (let step = 0; step < 5; step++) {
            eccentric = eccentric - (eccentric - eccentricity * Math.sin(eccentric) - mean) / (1 - eccentricity * Math.cos(eccentric));
        }
        return eccentric;
    }

    function orbitalState(planet: var, dayOffset: real): var {
        const a = planetA(planet);
        const e = planetE(planet);
        const i = degToRad(planetI(planet));
        const node = degToRad(planetNode(planet));
        const peri = degToRad(planetPeri(planet));
        const anomaly = meanAnomaly(planet, dayOffset);
        const eccentric = solveKepler(anomaly, e);
        const xv = a * (Math.cos(eccentric) - e);
        const yv = a * Math.sqrt(1 - e * e) * Math.sin(eccentric);
        const trueAnomaly = Math.atan2(yv, xv);
        const radius = Math.sqrt(xv * xv + yv * yv);
        const argument = trueAnomaly + peri - node;
        const cosNode = Math.cos(node);
        const sinNode = Math.sin(node);
        const cosArg = Math.cos(argument);
        const sinArg = Math.sin(argument);
        const cosI = Math.cos(i);
        const sinI = Math.sin(i);
        const x = radius * (cosNode * cosArg - sinNode * sinArg * cosI);
        const y = radius * (sinNode * cosArg + cosNode * sinArg * cosI);
        const z = radius * (sinArg * sinI);

        return {
            x: x,
            y: y,
            z: z,
            r: radius,
            meanAnomaly: positiveDegrees(anomaly),
            trueLongitude: positiveDegrees((Math.atan2(y, x) * 180 / Math.PI)),
            eccentricAnomaly: positiveDegrees(eccentric * 180 / Math.PI)
        };
    }

    function viewScale(): real {
        return mapSize * 0.43 * zoomLevel / 30.2;
    }

    function projectPoint(point: var): var {
        const yaw = degToRad(yawDeg);
        const pitch = degToRad(pitchDeg);
        const cosYaw = Math.cos(yaw);
        const sinYaw = Math.sin(yaw);
        const cosPitch = Math.cos(pitch);
        const sinPitch = Math.sin(pitch);
        const x1 = point.x * cosYaw - point.y * sinYaw;
        const y1 = point.x * sinYaw + point.y * cosYaw;
        const z1 = point.z;
        const y2 = y1 * cosPitch - z1 * sinPitch;
        const z2 = y1 * sinPitch + z1 * cosPitch;
        const perspective = 1 / (1 + z2 * 0.016);

        return {
            x: mapCenterX + x1 * viewScale() * perspective,
            y: mapCenterY + y2 * viewScale() * perspective,
            depth: z2,
            perspective: perspective
        };
    }

    function projectedPlanet(planet: var): var {
        const state = orbitalState(planet, daysSinceEpoch);
        const projected = projectPoint(state);
        return {
            x: projected.x,
            y: projected.y,
            depth: projected.depth,
            perspective: projected.perspective,
            r: state.r,
            z: state.z,
            meanAnomaly: state.meanAnomaly,
            trueLongitude: state.trueLongitude,
            eccentricAnomaly: state.eccentricAnomaly
        };
    }

    function earthState(): var {
        return orbitalState(planets[2], daysSinceEpoch);
    }

    function labelX(projected: var, labelWidth: real): real {
        const preferred = projected.depth >= 0 ? projected.x + 16 : projected.x - labelWidth - 16;
        return Math.min(width - labelWidth - 10, Math.max(10, preferred));
    }

    function labelY(projected: var, labelHeight: real): real {
        return Math.min(height - labelHeight - 72, Math.max(42, projected.y - labelHeight / 2));
    }

    function formattedPeriod(planet: var): string {
        const period = planetPeriod(planet);
        return period >= 1000 ? (period / 365.256).toFixed(1) + "Y" : period.toFixed(1) + "D";
    }

    function planetLine(planet: var): string {
        const state = orbitalState(planet, daysSinceEpoch);
        return planetCode(planet) + " XYZ " + state.x.toFixed(2) + " " + state.y.toFixed(2) + " " + state.z.toFixed(2) + " AU // LON " + state.trueLongitude.toFixed(1) + " // M " + state.meanAnomaly.toFixed(1);
    }

    function planetCoordinateLabel(planet: var): string {
        const state = orbitalState(planet, daysSinceEpoch);
        return planetCode(planet) + " X " + state.x.toFixed(2) + " Y " + state.y.toFixed(2) + " Z " + state.z.toFixed(2) + " AU";
    }

    function requestScenePaint(): void {
        orbitCanvas.requestPaint();
    }

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
        requestScenePaint();
    }

    onDaysSinceEpochChanged: requestScenePaint()
    onYawDegChanged: requestScenePaint()
    onPitchDegChanged: requestScenePaint()
    onZoomLevelChanged: requestScenePaint()
    onOrbitSampleCountChanged: requestScenePaint()
    onWidthChanged: requestScenePaint()
    onHeightChanged: requestScenePaint()

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
    }

    Canvas {
        id: orbitCanvas

        anchors.fill: parent
        opacity: 0.98
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            const accent = Theme.line.toString();
            const dim = Theme.border.toString();
            const lineDim = Theme.lineDim.toString();
            const textDim = Theme.textDim.toString();
            const cx = root.mapCenterX;
            const cy = root.mapCenterY;
            const gridRadius = root.mapSize * 0.46 * root.zoomLevel;

            ctx.save();
            ctx.globalAlpha = 0.12;
            ctx.strokeStyle = accent;
            ctx.lineWidth = 1;
            for (let ring = 1; ring <= 5; ring++) {
                ctx.beginPath();
                ctx.arc(cx, cy, gridRadius * ring / 5, 0, Math.PI * 2);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.2;
            for (let axis = 0; axis < 12; axis++) {
                const angle = axis * Math.PI / 6;
                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle) * 32, cy + Math.sin(angle) * 32);
                ctx.lineTo(cx + Math.cos(angle) * gridRadius, cy + Math.sin(angle) * gridRadius);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.24;
            ctx.strokeStyle = textDim;
            ctx.beginPath();
            ctx.moveTo(cx - gridRadius, cy);
            ctx.lineTo(cx + gridRadius, cy);
            ctx.moveTo(cx, cy - gridRadius);
            ctx.lineTo(cx, cy + gridRadius);
            ctx.stroke();

            for (let p = 0; p < root.planets.length; p++) {
                const planet = root.planets[p];
                ctx.beginPath();
                for (let sample = 0; sample <= root.orbitSampleCount; sample++) {
                    const dayOffset = root.daysSinceEpoch + sample * root.planetPeriod(planet) / root.orbitSampleCount;
                    const projected = root.projectPoint(root.orbitalState(planet, dayOffset));
                    if (sample === 0)
                        ctx.moveTo(projected.x, projected.y);
                    else
                        ctx.lineTo(projected.x, projected.y);
                }
                ctx.globalAlpha = 0.22 + p * 0.035;
                ctx.strokeStyle = p === 2 ? accent : dim;
                ctx.lineWidth = p === 2 ? 1.6 : 0.9;
                ctx.stroke();
            }

            ctx.globalAlpha = 0.34;
            ctx.strokeStyle = accent;
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(cx, cy, 24, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(cx - 42, cy);
            ctx.lineTo(cx + 42, cy);
            ctx.moveTo(cx, cy - 42);
            ctx.lineTo(cx, cy + 42);
            ctx.stroke();

            ctx.globalAlpha = 0.38;
            ctx.fillStyle = accent;
            ctx.font = Theme.fontTiny + "px " + Theme.fontFamily;
            ctx.fillText("ECLIPTIC XYZ FRAME // J2000 // AU", 18, height - 26);
            ctx.fillText("YAW " + Math.round(root.yawDeg) + " // PITCH " + Math.round(root.pitchDeg) + " // ZOOM " + root.zoomLevel.toFixed(2) + "X", width - 326, height - 26);
            ctx.globalAlpha = 0.3;
            ctx.fillText("+X VERNAL", cx + gridRadius + 8, cy + 4);
            ctx.fillText("+Y ECLIPTIC", cx + 8, cy - gridRadius - 8);

            ctx.globalAlpha = 0.16;
            ctx.strokeStyle = lineDim;
            for (let scan = 0; scan < height; scan += 18) {
                ctx.beginPath();
                ctx.moveTo(0, scan);
                ctx.lineTo(width, scan);
                ctx.stroke();
            }

            ctx.restore();
        }
    }

    MouseArea {
        id: viewDragArea

        anchors.fill: parent
        anchors.topMargin: 42
        anchors.bottomMargin: 52
        acceptedButtons: Qt.LeftButton
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        preventStealing: true
        propagateComposedEvents: false
        onPressed: mouse => {
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
            required property var modelData

            readonly property var projected: root.projectedPlanet(modelData)
            readonly property real nodeSize: root.planetSize(modelData) * Math.max(0.72, Math.min(1.28, projected.perspective))

            Repeater {
                model: 5

                Rectangle {
                    required property int index

                    readonly property var trailState: root.orbitalState(parent.modelData, root.daysSinceEpoch - (index + 1) * Math.max(3, 460 / root.planetPeriod(parent.modelData)))
                    readonly property var trailPoint: root.projectPoint(trailState)

                    x: trailPoint.x - width / 2
                    y: trailPoint.y - height / 2
                    width: Math.max(2, parent.nodeSize - index * 1.45)
                    height: width
                    radius: width / 2
                    color: Theme.line
                    opacity: 0.25 - index * 0.035
                }
            }

            Rectangle {
                x: parent.projected.x - width / 2
                y: parent.projected.y - height / 2
                width: parent.nodeSize + 12
                height: width
                radius: width / 2
                color: "transparent"
                border.color: Theme.line
                border.width: Theme.lineWidth
                opacity: 0.22 + Math.max(0, parent.projected.depth) * 0.008
            }

            Rectangle {
                x: parent.projected.x - width / 2
                y: parent.projected.y - height / 2
                width: parent.nodeSize
                height: width
                radius: width / 2
                color: root.planetCode(modelData) === "EA" ? Theme.text : Theme.line
                opacity: parent.projected.depth >= 0 ? 0.98 : 0.58
            }

            Rectangle {
                x: parent.projected.x - 1
                y: parent.projected.y - 14
                width: 2
                height: 28
                color: Theme.line
                opacity: 0.3
            }

            Rectangle {
                x: parent.projected.x - 14
                y: parent.projected.y - 1
                width: 28
                height: 2
                color: Theme.line
                opacity: 0.3
            }

            TacticalLabel {
                id: labelProbe

                visible: false
                text: root.planetCoordinateLabel(modelData)
                size: Theme.fontTiny
            }

            Rectangle {
                x: parent.projected.depth >= 0 ? parent.projected.x + 6 : root.labelX(parent.projected, labelProbe.implicitWidth) + labelProbe.implicitWidth
                y: parent.projected.y
                width: Math.max(8, Math.abs(root.labelX(parent.projected, labelProbe.implicitWidth) - parent.projected.x) - 10)
                height: Theme.lineWidth
                color: Theme.lineDim
                opacity: 0.38
            }

            TacticalLabel {
                x: root.labelX(parent.projected, implicitWidth)
                y: root.labelY(parent.projected, implicitHeight)
                text: labelProbe.text
                accent: parent.projected.depth >= 0
                dim: parent.projected.depth < 0
                size: Theme.fontTiny
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: Math.min(parent.width * 0.47, 440)
        height: Math.min(parent.height * 0.43, ephemerisColumn.implicitHeight + 22)
        color: "#33000000"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth

        ColumnLayout {
            id: ephemerisColumn

            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            TacticalLabel {
                Layout.fillWidth: true
                text: "APPROX EPHEMERIS // J2000 KEPLER // HELIOCENTRIC AU"
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            Repeater {
                model: root.planets

                RowLayout {
                    required property var modelData

                    Layout.fillWidth: true
                    spacing: 8

                    TacticalLabel {
                        text: root.planetCode(modelData)
                        accent: true
                        size: Theme.fontTiny
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: root.planetLine(modelData)
                        dim: root.planetCode(modelData) !== "EA"
                        accent: root.planetCode(modelData) === "EA"
                        size: Theme.fontTiny
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: Math.min(parent.width * 0.31, 280)
        height: controlsColumn.implicitHeight + 20
        color: "#33000000"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth

        ColumnLayout {
            id: controlsColumn

            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            TacticalLabel {
                Layout.fillWidth: true
                text: "VIEW CONTROL // DRAG ROTATE // WHEEL ZOOM 0.42X-4.20X"
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "YAW " + Math.round(root.yawDeg) + " DEG // PITCH " + Math.round(root.pitchDeg) + " DEG // SCALE " + root.zoomLevel.toFixed(2) + "X"
                dim: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "EARTH XYZ " + root.earthState().x.toFixed(3) + " / " + root.earthState().y.toFixed(3) + " / " + root.earthState().z.toFixed(3) + " AU"
                accent: true
                size: Theme.fontTiny
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: 92
                Layout.preferredHeight: Theme.densityControlHeight
                color: resetArea.containsMouse ? Theme.lineDim : "transparent"
                border.color: resetArea.containsMouse ? Theme.line : Theme.lineDim
                border.width: Theme.lineWidth

                TacticalLabel {
                    anchors.centerIn: parent
                    text: "RESET VIEW"
                    accent: resetArea.containsMouse
                    size: Theme.fontTiny
                }

                MouseArea {
                    id: resetArea

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.resetView()
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 34
        height: 34
        radius: width / 2
        color: Theme.line
        opacity: 0.14
    }

    Rectangle {
        anchors.centerIn: parent
        width: 12
        height: 12
        radius: width / 2
        color: Theme.line
    }

    Repeater {
        model: 4

        Rectangle {
            required property int index

            readonly property bool rightSide: index === 1 || index === 3
            readonly property bool bottomSide: index >= 2

            x: rightSide ? parent.width - width : 0
            y: bottomSide ? parent.height - height : 0
            width: 82
            height: 82
            color: "transparent"

            Rectangle {
                width: parent.width
                height: Theme.lineWidth
                color: Theme.line
                anchors.top: parent.top
            }

            Rectangle {
                width: Theme.lineWidth
                height: parent.height
                color: Theme.line
                anchors.left: parent.left
            }

            transform: [
                Scale {
                    origin.x: parent.width / 2
                    origin.y: parent.height / 2
                    xScale: parent.rightSide ? -1 : 1
                    yScale: parent.bottomSide ? -1 : 1
                }
            ]
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
            text: "ORBIT SENSOR // UTC " + Qt.formatDateTime(Time.now, "yyyy-MM-dd hh:mm:ss") + " // J2000+" + Math.floor(root.daysSinceEpoch) + "D // KEPLER APPROX"
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

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: 26
        height: Theme.heavyLineWidth
        color: Theme.line
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: Theme.heavyLineWidth
        height: 26
        color: Theme.line
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 26
        height: Theme.heavyLineWidth
        color: Theme.line
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Theme.heavyLineWidth
        height: 26
        color: Theme.line
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
}
