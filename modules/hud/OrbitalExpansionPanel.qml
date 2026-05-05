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
    readonly property real orbitRadius: coreSize * 0.42
    readonly property var planets: [
        { name: "MERCURY", code: "ME", radius: 0.18, au: 0.387, period: 87.969, epochLongitude: 252.251, size: 5 },
        { name: "VENUS", code: "VE", radius: 0.26, au: 0.723, period: 224.701, epochLongitude: 181.979, size: 7 },
        { name: "EARTH", code: "EA", radius: 0.35, au: 1.0, period: 365.256, epochLongitude: 100.464, size: 8 },
        { name: "MARS", code: "MA", radius: 0.44, au: 1.524, period: 686.98, epochLongitude: 355.433, size: 6 },
        { name: "JUPITER", code: "JU", radius: 0.58, au: 5.203, period: 4332.589, epochLongitude: 34.351, size: 13 },
        { name: "SATURN", code: "SA", radius: 0.7, au: 9.537, period: 10759.22, epochLongitude: 50.077, size: 12 },
        { name: "URANUS", code: "UR", radius: 0.82, au: 19.191, period: 30685.4, epochLongitude: 314.055, size: 10 },
        { name: "NEPTUNE", code: "NE", radius: 0.93, au: 30.069, period: 60189.0, epochLongitude: 304.348, size: 10 }
    ]

    function planetName(planet: var): string {
        return typeof planet.name === "string" && planet.name.length > 0 ? planet.name : "UNKNOWN";
    }

    function planetCode(planet: var): string {
        return typeof planet.code === "string" && planet.code.length > 0 ? planet.code : planetName(planet).slice(0, 2).toUpperCase();
    }

    function planetRadiusScale(planet: var): real {
        return typeof planet.radius === "number" && planet.radius > 0 ? planet.radius : 0.5;
    }

    function planetPeriod(planet: var): real {
        return typeof planet.period === "number" && planet.period > 0 ? planet.period : 365.256;
    }

    function planetSize(planet: var): real {
        return typeof planet.size === "number" && planet.size > 0 ? planet.size : 7;
    }

    function planetAu(planet: var): real {
        return typeof planet.au === "number" && planet.au > 0 ? planet.au : 1;
    }

    function planetEpochLongitude(planet: var): real {
        return typeof planet.epochLongitude === "number" ? planet.epochLongitude : 0;
    }

    function planetAngle(planet: var): real {
        return positiveDegrees(planetEpochLongitude(planet) + daysSinceEpoch * 360 / planetPeriod(planet));
    }

    function positiveDegrees(value: real): real {
        const wrapped = value % 360;
        return wrapped < 0 ? wrapped + 360 : wrapped;
    }

    function orbitalProgress(planet: var): real {
        return positiveDegrees(planetAngle(planet) - planetEpochLongitude(planet)) / 360;
    }

    function formattedLongitude(planet: var): string {
        return planetAngle(planet).toFixed(1) + " DEG";
    }

    function formattedPeriod(planet: var): string {
        const period = planetPeriod(planet);
        return period >= 1000 ? (period / 365.256).toFixed(1) + " Y" : period.toFixed(1) + " D";
    }

    function planetLine(planet: var): string {
        return planetCode(planet) + " " + formattedLongitude(planet) + " // " + planetAu(planet).toFixed(3) + " AU // " + formattedPeriod(planet);
    }

    function planetX(planet: var, angleOffset: real): real {
        const angle = (planetAngle(planet) + angleOffset) * Math.PI / 180;
        return width / 2 + Math.cos(angle) * orbitRadius * planetRadiusScale(planet);
    }

    function planetY(planet: var, angleOffset: real): real {
        const angle = (planetAngle(planet) + angleOffset) * Math.PI / 180;
        return height / 2 + Math.sin(angle) * orbitRadius * planetRadiusScale(planet) * 0.58;
    }

    function labelOnRight(planet: var): bool {
        return Math.cos(planetAngle(planet) * Math.PI / 180) >= 0;
    }

    function labelX(planet: var, px: real, labelWidth: real): real {
        const preferred = labelOnRight(planet) ? px + 16 : px - labelWidth - 16;
        return Math.min(width - labelWidth - 10, Math.max(10, preferred));
    }

    function labelY(py: real, labelHeight: real): real {
        return Math.min(height - labelHeight - 10, Math.max(42, py - labelHeight / 2));
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
        opacity: 0.96
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            const cx = width / 2;
            const cy = height / 2;
            const radius = root.orbitRadius;
            const dim = Theme.border.toString();
            const textDim = Theme.textDim.toString();
            const accent = Theme.line.toString();

            ctx.save();
            ctx.translate(cx, cy);

            ctx.strokeStyle = dim;
            for (let i = 0; i < root.planets.length; i++) {
                const orbit = root.planetRadiusScale(root.planets[i]) * radius;
                ctx.lineWidth = i % 2 === 0 ? 1.3 : 0.8;
                ctx.globalAlpha = 0.34 + i * 0.045;
                ctx.beginPath();
                ctx.ellipse(0, 0, orbit, orbit * 0.58, 0, 0, Math.PI * 2);
                ctx.stroke();

                if (i % 2 === 0) {
                    ctx.globalAlpha = 0.12;
                    ctx.strokeStyle = accent;
                    ctx.beginPath();
                    ctx.ellipse(0, 0, orbit + 4, orbit * 0.58 + 2, 0, -Math.PI * 0.08, Math.PI * 0.16);
                    ctx.stroke();
                    ctx.strokeStyle = dim;
                }
            }

            ctx.globalAlpha = 0.36;
            ctx.strokeStyle = accent;
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(0, 0, 24, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(-38, 0);
            ctx.lineTo(38, 0);
            ctx.moveTo(0, -38);
            ctx.lineTo(0, 38);
            ctx.stroke();

            ctx.globalAlpha = 0.26;
            ctx.strokeStyle = textDim;
            for (let tick = 0; tick < 48; tick++) {
                const angle = tick * Math.PI / 24;
                const outer = radius * 1.03;
                const inner = outer - (tick % 4 === 0 ? 16 : 8);
                ctx.beginPath();
                ctx.moveTo(Math.cos(angle) * inner, Math.sin(angle) * inner * 0.58);
                ctx.lineTo(Math.cos(angle) * outer, Math.sin(angle) * outer * 0.58);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.16;
            ctx.strokeStyle = accent;
            ctx.lineWidth = 1;
            for (let spoke = 0; spoke < 8; spoke++) {
                const angle = spoke * Math.PI / 4;
                ctx.beginPath();
                ctx.moveTo(Math.cos(angle) * 52, Math.sin(angle) * 52 * 0.58);
                ctx.lineTo(Math.cos(angle) * radius * 0.98, Math.sin(angle) * radius * 0.98 * 0.58);
                ctx.stroke();
            }

            ctx.restore();
        }

        Connections {
            target: root
            function onWidthChanged(): void {
                orbitCanvas.requestPaint();
            }
            function onHeightChanged(): void {
                orbitCanvas.requestPaint();
            }
        }
    }

    Repeater {
        model: root.planets

        Item {
            required property var modelData

            readonly property real px: root.planetX(modelData, 0)
            readonly property real py: root.planetY(modelData, 0)

            Repeater {
                model: 5

                Rectangle {
                    required property int index

                    readonly property real trailStep: (index + 1) * Math.max(2, 720 / root.planetPeriod(parent.modelData))
                    readonly property real trailX: root.planetX(parent.modelData, -trailStep)
                    readonly property real trailY: root.planetY(parent.modelData, -trailStep)

                    x: trailX - width / 2
                    y: trailY - height / 2
                    width: Math.max(2, root.planetSize(parent.modelData) - index * 1.6)
                    height: width
                    radius: width / 2
                    color: Theme.line
                    opacity: 0.26 - index * 0.035
                }
            }

            Rectangle {
                x: parent.px - width / 2
                y: parent.py - height / 2
                width: root.planetSize(modelData) + 10
                height: width
                radius: width / 2
                color: "transparent"
                border.color: Theme.line
                border.width: Theme.lineWidth
                opacity: 0.28
            }

            Rectangle {
                x: parent.px - width / 2
                y: parent.py - height / 2
                width: root.planetSize(modelData)
                height: width
                radius: width / 2
                color: Theme.line
                opacity: 0.95
            }

            Rectangle {
                x: parent.px - 1
                y: parent.py - 14
                width: 2
                height: 28
                color: Theme.line
                opacity: 0.32
            }

            Rectangle {
                x: parent.px - 14
                y: parent.py - 1
                width: 28
                height: 2
                color: Theme.line
                opacity: 0.32
            }

            TacticalLabel {
                x: root.labelX(modelData, parent.px, implicitWidth)
                y: root.labelY(parent.py, implicitHeight)
                text: root.planetCode(modelData) + " // " + Math.round(root.planetAngle(modelData)) + "° // " + root.planetAu(modelData).toFixed(1) + "AU"
                accent: true
                size: Theme.fontTiny
            }

            Rectangle {
                x: root.labelOnRight(modelData) ? parent.px + 6 : root.labelX(modelData, parent.px, labelProbe.implicitWidth) + labelProbe.implicitWidth
                y: parent.py
                width: Math.max(8, Math.abs(root.labelX(modelData, parent.px, labelProbe.implicitWidth) - parent.px) - 10)
                height: Theme.lineWidth
                color: Theme.lineDim
                opacity: 0.42
            }

            TacticalLabel {
                id: labelProbe

                visible: false
                text: root.planetCode(modelData) + " // " + Math.round(root.planetAngle(modelData)) + "° // " + root.planetAu(modelData).toFixed(1) + "AU"
                size: Theme.fontTiny
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: Math.min(parent.width * 0.42, 360)
        height: Math.min(parent.height * 0.36, ephemerisColumn.implicitHeight + 22)
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
                text: "APPROX EPHEMERIS // J2000 CIRCULAR"
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
        anchors.centerIn: parent
        width: 34
        height: 34
        radius: width / 2
        color: Theme.line
        opacity: 0.18
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
            text: "ORBIT SENSOR // UTC " + Qt.formatDateTime(Time.now, "yyyy-MM-dd hh:mm:ss") + " // J2000+" + Math.floor(root.daysSinceEpoch) + "D // APPROX"
            accent: true
            size: Theme.fontTiny
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
