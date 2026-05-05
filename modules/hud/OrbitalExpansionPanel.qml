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

    function planetAngle(planet: var): real {
        return positiveDegrees(planet.epochLongitude + daysSinceEpoch * 360 / planet.period);
    }

    function positiveDegrees(value: real): real {
        const wrapped = value % 360;
        return wrapped < 0 ? wrapped + 360 : wrapped;
    }

    function orbitalProgress(planet: var): real {
        return positiveDegrees(planetAngle(planet) - planet.epochLongitude) / 360;
    }

    function formattedLongitude(planet: var): string {
        return planetAngle(planet).toFixed(1) + " DEG";
    }

    function formattedPeriod(planet: var): string {
        return planet.period >= 1000 ? (planet.period / 365.256).toFixed(1) + " Y" : planet.period.toFixed(1) + " D";
    }

    function planetLine(planet: var): string {
        return planet.code + " " + formattedLongitude(planet) + " // " + planet.au.toFixed(3) + " AU // " + formattedPeriod(planet);
    }

    function planetX(planet: var, angleOffset: real): real {
        const angle = (planetAngle(planet) + angleOffset) * Math.PI / 180;
        return width / 2 + Math.cos(angle) * orbitRadius * planet.radius;
    }

    function planetY(planet: var, angleOffset: real): real {
        const angle = (planetAngle(planet) + angleOffset) * Math.PI / 180;
        return height / 2 + Math.sin(angle) * orbitRadius * planet.radius * 0.58;
    }

    Rectangle {
        anchors.fill: parent
        color: "#24000000"
    }

    ScanlineOverlay {
        anchors.fill: parent
        lineOpacity: 0.035 * SettingsService.intensity
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

            ctx.save();
            ctx.translate(cx, cy);

            ctx.strokeStyle = dim;
            ctx.lineWidth = 1;
            ctx.globalAlpha = 0.7;
            for (let i = 0; i < root.planets.length; i++) {
                const orbit = root.planets[i].radius * radius;
                ctx.beginPath();
                ctx.ellipse(0, 0, orbit, orbit * 0.58, 0, 0, Math.PI * 2);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.32;
            ctx.strokeStyle = Theme.line.toString();
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

                    readonly property real trailStep: (index + 1) * Math.max(2, 720 / parent.modelData.period)
                    readonly property real trailX: root.planetX(parent.modelData, -trailStep)
                    readonly property real trailY: root.planetY(parent.modelData, -trailStep)

                    x: trailX - width / 2
                    y: trailY - height / 2
                    width: Math.max(2, parent.modelData.size - index * 1.6)
                    height: width
                    radius: width / 2
                    color: Theme.line
                    opacity: 0.26 - index * 0.035
                }
            }

            Rectangle {
                x: parent.px - width / 2
                y: parent.py - height / 2
                width: modelData.size + 10
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
                width: modelData.size
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
                x: Math.min(root.width - implicitWidth - 8, Math.max(8, parent.px + 12))
                y: Math.min(root.height - implicitHeight - 8, Math.max(8, parent.py - 18))
                text: modelData.code + " // " + Math.round(root.planetAngle(modelData)) + "° // " + modelData.au.toFixed(1) + "AU"
                accent: true
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
                        text: modelData.code
                        accent: true
                        size: Theme.fontTiny
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: root.planetLine(modelData)
                        dim: modelData.code !== "EA"
                        accent: modelData.code === "EA"
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
        anchors.margins: 10
        width: Math.min(parent.width - 116, statusText.implicitWidth + 18)
        height: 28
        color: "#33000000"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth

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
        anchors.margins: 10
        onCloseRequested: ExpansionService.close()
    }
}
