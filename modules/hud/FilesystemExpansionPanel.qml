import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "FILESYSTEM MATRIX // STORAGE DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT FILESYSTEM NODE // DF -B1 STORAGE TELEMETRY"

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
        spacing: Theme.densitySpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                Repeater {
                    model: SystemStats.filesystemRows

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityCardHeight
                        color: modelData[2] >= 0.7 ? Theme.lineDim : "#44000000"
                        border.color: modelData[2] >= 0.7 ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: Theme.densitySmallSpacing * 0.75

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
                                Layout.preferredHeight: Theme.densityProgressHeight
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
                spacing: Theme.densitySpacing

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
