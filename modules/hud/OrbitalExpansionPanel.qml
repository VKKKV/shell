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
    readonly property int mapColumns: Math.max(48, Math.min(108, Math.floor((orbitViewport.width - 24) / 9)))
    readonly property int mapRows: Math.max(22, Math.min(44, Math.floor((orbitViewport.height - 24) / 17)))
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
        const width = mapColumns;
        const height = mapRows;
        const grid = [];
        const centerX = Math.floor(width / 2);
        const centerY = Math.floor(height / 2);
        const ratio = width / Math.max(1, height) * 0.46;
        for (let y = 0; y < height; y++) {
            let row = "";
            for (let x = 0; x < width; x++) {
                const dx = (x - centerX) / (width / 2);
                const dy = (y - centerY) / (height / 2) / ratio;
                const distance = Math.sqrt(dx * dx + dy * dy);
                let glyph = " ";
                for (const planet of planets) {
                    if (Math.abs(distance - planet.radius) < 0.012) {
                        glyph = ".";
                        break;
                    }
                }
                if (Math.abs(y - centerY) < 1 && x % 8 === 0)
                    glyph = "-";
                if (Math.abs(x - centerX) < 1 && y % 4 === 0)
                    glyph = "|";
                row += glyph;
            }
            grid.push(row);
        }

        grid[centerY] = replaceAt(grid[centerY], centerX - 1, "SU");
        for (const planet of planets) {
            const angle = planetAngle(planet) * Math.PI / 180;
            const px = Math.round(centerX + Math.cos(angle) * planet.radius * width * 0.49);
            const py = Math.round(centerY + Math.sin(angle) * planet.radius * height * 0.49 * ratio);
            for (let trail = 1; trail <= 8; trail++) {
                const trailAngle = (planetAngle(planet) - trail * (3 + planet.speed)) * Math.PI / 180;
                const tx = Math.round(centerX + Math.cos(trailAngle) * planet.radius * width * 0.49);
                const ty = Math.round(centerY + Math.sin(trailAngle) * planet.radius * height * 0.49 * ratio);
                if (ty >= 0 && ty < height && tx >= 0 && tx < width)
                    grid[ty] = replaceAt(grid[ty], tx, trail < 3 ? "+" : "·");
            }
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
                id: orbitViewport

                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#55000000"
                border.color: Theme.lineDim
                border.width: Theme.lineWidth
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "ASCII ORBITAL PLANE // " + root.mapColumns + "x" + root.mapRows + " // TRACK TRACE +/· // TRANSPARENT SAFE AREA"
                        accent: true
                        elide: Text.ElideRight
                    }

                    Column {
                        Layout.alignment: Qt.AlignCenter
                        spacing: 0

                        Repeater {
                            model: root.asciiMap

                            Text {
                                required property string modelData

                                text: modelData
                                color: text.indexOf("SU") >= 0 ? Theme.line : Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Math.max(10, Math.min(15, (orbitViewport.height - 64) / Math.max(1, root.mapRows)))
                                font.letterSpacing: Math.max(0, Math.min(2.2, (orbitViewport.width / Math.max(1, root.mapColumns)) - 7.8))
                                font.bold: text.indexOf("SU") >= 0 || /ME|VE|EA|MA|JU|SA|UR|NE/.test(text)
                            }
                        }
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
