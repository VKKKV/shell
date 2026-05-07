import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "MEDIA BUS // PLAYER DRILLDOWN"
    headerText: "DEPLOYED FROM LEFT TELEMETRY NODE // PLAYERCTL + LOCAL LYRIC INDEX"

    readonly property string trackLine: MediaService.artist.length > 0 ? MediaService.artist + " // " + MediaService.title : MediaService.title

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                MetricBlock {
                    title: "PLAYER STATE"
                    rows: [["PLAYER", MediaService.player.length > 0 ? MediaService.player.toUpperCase() : "NONE", MediaService.available ? 1 : -1, MediaService.available], ["STATUS", MediaService.status, MediaService.available ? 1 : -1, MediaService.available && MediaService.status === "PLAYING"], ["AUDIO", AudioService.volumeText, AudioService.available ? AudioService.volume : -1, AudioService.available && !AudioService.muted], ["LYRICS", MediaService.lyricStatusLine, MediaService.lyricLines.length > 0 ? 1 : -1, MediaService.lyricStatusLine.indexOf("file") >= 0]]
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(140, Theme.densityGraphHeight + Theme.densityControlHeight)
                    color: "#55000000"
                    border.color: MediaService.available ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.panelPadding
                        spacing: Theme.densitySpacing

                        TacticalLabel {
                            Layout.fillWidth: true
                            text: "TRACK // " + root.trackLine
                            accent: MediaService.available
                            dim: !MediaService.available
                            elide: Text.ElideRight
                        }

                        Sparkline {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.densityGraphHeight
                            values: AudioService.spectrum
                            barColor: MediaService.available && AudioService.available && !AudioService.muted ? Theme.line : Theme.lineDim
                        }

                        TextBlock {
                            Layout.fillWidth: true
                            title: "MEDIA STATUS"
                            lines: [MediaService.statusLine, MediaService.displayText, "PLAYER: " + (MediaService.player.length > 0 ? MediaService.player : "none"), "MODE: LOCAL PLAYERCTL CONTROL"]
                        }
                    }
                }

                TextBlock {
                    title: "LYRICS // LOCAL"
                    lines: [MediaService.lyricStatusLine].concat(MediaService.lyricLines)
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                TacticalLabel {
                    Layout.fillWidth: true
                    text: "TRANSPORT CONTROL"
                    accent: MediaService.available
                    dim: !MediaService.available
                }

                Repeater {
                    model: [
                        ["PREVIOUS", "previous"],
                        [MediaService.status === "PLAYING" ? "PAUSE" : "PLAY", "play-pause"],
                        ["NEXT", "next"]
                    ]

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityControlHeight
                        color: transportArea.containsMouse ? Theme.panelSoft : "transparent"
                        border.color: MediaService.available ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth
                        opacity: MediaService.available ? 1 : 0.45

                        MouseArea {
                            id: transportArea

                            anchors.fill: parent
                            cursorShape: MediaService.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: MediaService.available
                            hoverEnabled: true
                            onClicked: MediaService.control(parent.modelData[1])
                        }

                        TacticalLabel {
                            anchors.centerIn: parent
                            text: parent.modelData[0]
                            accent: transportArea.containsMouse
                            dim: !MediaService.available
                        }
                    }
                }

                TextBlock {
                    Layout.fillWidth: true
                    title: "LYRIC INDEX CONTRACT"
                    lines: ["PATH: ~/Music/Lyrics", "PATH: ~/.local/share/lyrics", "FORMAT: Artist - Title.lrc", "FORMAT: Title.txt", "CLICK BACKDROP OR CLOSE TO DISMISS"]
                }
            }
        }
    }
}
