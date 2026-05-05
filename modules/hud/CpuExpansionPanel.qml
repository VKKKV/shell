import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "CPU MATRIX // CORE DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT MONITOR MATRIX // LIVE /PROC STAT TELEMETRY"

    function heatGlyph(value: real): string {
        if (value >= 0.8)
            return "████";
        if (value >= 0.55)
            return "▓▓▓░";
        if (value >= 0.3)
            return "▒▒░░";
        return "░░░░";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 3
                columnSpacing: Theme.densitySmallSpacing
                rowSpacing: Theme.densitySmallSpacing

                Repeater {
                    model: SystemStats.cpuRows

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityCardHeight
                        color: modelData[3] ? Theme.lineDim : "#66000000"
                        border.color: modelData[3] ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: Theme.densitySmallSpacing * 0.5

                            RowLayout {
                                Layout.fillWidth: true

                                TacticalLabel {
                                    Layout.fillWidth: true
                                    text: modelData[0]
                                    accent: true
                                }

                                TacticalLabel {
                                    text: modelData[1]
                                    accent: modelData[3]
                                }
                            }

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: root.heatGlyph(modelData[2])
                                accent: modelData[3]
                                size: Theme.fontNormal
                                font.letterSpacing: 2
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(4, Theme.densityProgressHeight - 3)
                                color: "transparent"
                                border.color: Theme.lineDim
                                border.width: Theme.lineWidth

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * Math.max(0, Math.min(1, modelData[2]))
                                    color: modelData[3] ? Theme.line : Theme.lineDim
                                }
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
                    title: "PROCESSOR BUS"
                    lines: [SystemStats.statusLine, "ROWS: " + SystemStats.cpuRows.length, "POLL: " + (SettingsService.updateIntervalMs / 1000).toFixed(0) + "S", "MODE: EDGE NODE DRILLDOWN", "ALERT: LOAD > 75%"]
                }

                Sparkline {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.densityGraphHeight
                    values: SystemStats.cpuHistory
                }

                TextBlock {
                    title: "THERMAL LANGUAGE"
                    lines: ["░░░░ LOW ACTIVITY", "▒▒░░ NOMINAL", "▓▓▓░ HIGH", "████ ALERT", "CLICK BACKDROP TO DISMISS"]
                }
            }
        }
    }
}
