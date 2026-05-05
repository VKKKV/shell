import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "FILESYSTEM MATRIX // STORAGE DRILLDOWN"
    highlighted: true

    function glyph(value: real): string {
        if (value >= 0.85)
            return "CRITICAL";
        if (value >= 0.7)
            return "WARN";
        if (value >= 0.45)
            return "ACTIVE";
        return "STABLE";
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
                text: "DEPLOYED FROM RIGHT FILESYSTEM NODE // DF -B1 STORAGE TELEMETRY"
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

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Repeater {
                    model: SystemStats.filesystemRows

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        color: modelData[2] >= 0.7 ? Theme.lineDim : "#44000000"
                        border.color: modelData[2] >= 0.7 ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 5

                            RowLayout {
                                Layout.fillWidth: true

                                TacticalLabel {
                                    Layout.fillWidth: true
                                    text: modelData[0]
                                    accent: true
                                }

                                TacticalLabel {
                                    text: root.glyph(modelData[2]) + " // " + modelData[1]
                                    accent: modelData[2] >= 0.7
                                    dim: modelData[2] < 0.7
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                                color: "transparent"
                                border.color: Theme.lineDim
                                border.width: Theme.lineWidth

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * Math.max(0, Math.min(1, modelData[2]))
                                    color: modelData[2] >= 0.7 ? Theme.line : Theme.lineDim
                                }
                            }

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: "MOUNT_STATUS // " + (modelData[3] ? "PRIORITY" : "MONITORED")
                                dim: true
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                spacing: 10

                TextBlock {
                    title: "STORAGE STATUS"
                    lines: [SystemStats.statusLine, "MOUNTS: " + SystemStats.filesystemRows.length, "SOURCE: df -B1", "TARGETS: / /home /data", "FAILSAFE: missing mounts skipped"]
                }

                MetricBlock {
                    title: "MEMORY COUPLING"
                    rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false]]
                }

                TextBlock {
                    title: "TACTICAL NOTES"
                    lines: ["CLICK BACKDROP TO DISMISS", "LOW SPACE: >= 70%", "CRITICAL: >= 85%", "MOUNT ACTIONS: DEFERRED"]
                }
            }
        }
    }
}
