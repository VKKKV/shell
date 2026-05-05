import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "ORBITAL ANALYSIS // SOL SYSTEM"
    highlighted: true

    property real phase: 0
    readonly property var planets: [
        { name: "MERCURY", code: "ME", radius: 0.16, speed: 4.15 },
        { name: "VENUS", code: "VE", radius: 0.24, speed: 1.62 },
        { name: "EARTH", code: "EA", radius: 0.32, speed: 1.0 },
        { name: "MARS", code: "MA", radius: 0.42, speed: 0.53 },
        { name: "JUPITER", code: "JU", radius: 0.55, speed: 0.084 },
        { name: "SATURN", code: "SA", radius: 0.68, speed: 0.034 },
        { name: "URANUS", code: "UR", radius: 0.8, speed: 0.012 },
        { name: "NEPTUNE", code: "NE", radius: 0.91, speed: 0.006 }
    ]
    readonly property var asciiMap: buildAsciiMap()

    function planetAngle(planet: var): real {
        return (phase * planet.speed + planet.radius * 720) % 360;
    }

    function buildAsciiMap(): var {
        const width = 42;
        const height = 19;
        const grid = [];
        for (let y = 0; y < height; y++) {
            let row = "";
            for (let x = 0; x < width; x++) {
                const dx = (x - width / 2) / (width / 2);
                const dy = (y - height / 2) / (height / 2);
                const distance = Math.sqrt(dx * dx + dy * dy);
                const orbit = Math.abs((distance * 10) % 1) < 0.045;
                row += orbit ? "." : " ";
            }
            grid.push(row);
        }

        grid[Math.floor(height / 2)] = replaceAt(grid[Math.floor(height / 2)], Math.floor(width / 2) - 1, "SU");
        for (const planet of planets) {
            const angle = planetAngle(planet) * Math.PI / 180;
            const px = Math.round(width / 2 + Math.cos(angle) * planet.radius * width * 0.47);
            const py = Math.round(height / 2 + Math.sin(angle) * planet.radius * height * 0.46);
            if (py >= 0 && py < height && px >= 0 && px < width - 1)
                grid[py] = replaceAt(grid[py], px, planet.code);
        }
        return grid;
    }

    function replaceAt(row: string, index: int, value: string): string {
        return row.substring(0, index) + value + row.substring(index + value.length);
    }

    NumberAnimation on phase {
        from: 0
        to: 360
        duration: 26000
        loops: Animation.Infinite
        running: root.visible
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 42
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TacticalLabel {
                Layout.fillWidth: true
                text: "DEPLOYED FROM LEFT ORBITAL NODE // LOCAL DETERMINISTIC EPHEMERIS"
                accent: true
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 26
                color: closeArea.containsMouse ? Theme.lineDim : "transparent"
                border.color: closeArea.containsMouse ? Theme.line : Theme.lineDim
                border.width: Theme.lineWidth

                MouseArea {
                    id: closeArea

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: ExpansionService.close()
                }

                TacticalLabel {
                    anchors.centerIn: parent
                    text: "CLOSE"
                    accent: closeArea.containsMouse
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#66000000"
                border.color: Theme.lineDim
                border.width: Theme.lineWidth
                clip: true

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        model: root.asciiMap

                        TacticalLabel {
                            required property string modelData

                            text: modelData
                            accent: text.indexOf("SU") >= 0
                            size: Theme.fontNormal
                            font.letterSpacing: 1.8
                        }
                    }
                }

                Repeater {
                    model: root.planets

                    Rectangle {
                        required property var modelData

                        readonly property real angle: root.planetAngle(modelData) * Math.PI / 180

                        width: 7
                        height: 7
                        radius: 0
                        color: Theme.line
                        x: parent.width / 2 + Math.cos(angle) * modelData.radius * parent.width * 0.43 - width / 2
                        y: parent.height / 2 + Math.sin(angle) * modelData.radius * parent.height * 0.42 - height / 2
                        opacity: 0.85
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                spacing: 10

                TextBlock {
                    title: "MECHANICAL STATUS"
                    lines: ["EXPANSION_LOCK: ENGAGED", "SCAN_MODE: TOP-DOWN", "DATA_SOURCE: LOCAL PHASE", "VISUAL: ASCII ORBITAL", "STYLE: VOID CYBERNETIC"]
                }

                MetricBlock {
                    title: "ORBITAL PHASE"
                    rows: [["PHASE", Math.round(root.phase) + " DEG", root.phase / 360, true], ["BODIES", root.planets.length.toString(), 1, false], ["SYNC", Time.timeText, -1, true]]
                }

                TextBlock {
                    title: "PLANET CODES"
                    lines: ["SU SUN // CORE", "ME MERCURY // INNER", "VE VENUS // INNER", "EA EARTH // HOME", "MA MARS // OUTER", "JU/SA/UR/NE // GIANTS"]
                }
            }
        }
    }
}
