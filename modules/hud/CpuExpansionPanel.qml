import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "CPU MATRIX // CORE DRILLDOWN"
    highlighted: true

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
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 42
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TacticalLabel {
                Layout.fillWidth: true
                text: "DEPLOYED FROM RIGHT MONITOR MATRIX // LIVE /PROC STAT TELEMETRY"
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

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 3
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: SystemStats.cpuRows

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 74
                        color: modelData[3] ? Theme.lineDim : "#66000000"
                        border.color: modelData[3] ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

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
                                Layout.preferredHeight: 5
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
                spacing: 10

                TextBlock {
                    title: "PROCESSOR BUS"
                    lines: [SystemStats.statusLine, "ROWS: " + SystemStats.cpuRows.length, "POLL: " + (SettingsService.updateIntervalMs / 1000).toFixed(0) + "S", "MODE: EDGE NODE DRILLDOWN", "ALERT: LOAD > 75%"]
                }

                Sparkline {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
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
