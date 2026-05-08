import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "LOG STREAM // EVENT DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT LOG NODE // SERVICE STATUS EVENT BUS"

    readonly property var logLines: [CompositorService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, AudioService.micStatusLine, BatteryService.statusLine, MediaService.statusLine, WeatherService.statusLine, KeyboardService.statusLine, PowerProfileService.statusLine, PowerProfileService.idleStatusLine].concat(SystemStats.logLines)
    readonly property int warningCount: logLines.filter(line => line.toLowerCase().indexOf("fallback") >= 0 || line.toLowerCase().indexOf("missing") >= 0).length

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        PanelStatusStrip {
            leftText: "EVENT BUS // LIVE"
            centerText: "LOG STREAM // " + root.logLines.length + " LINES"
            rightText: "ESC // CLOSE"
            warning: root.logLines.some(line => line.toLowerCase().indexOf("fallback") >= 0 || line.toLowerCase().indexOf("missing") >= 0)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#66000000"
                border.color: Theme.lineDim
                border.width: Theme.lineWidth
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: Theme.densitySmallSpacing

                    Repeater {
                        model: root.logLines

                        Rectangle {
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.densityRowHeight
                            color: modelData.indexOf("fallback") >= 0 || modelData.indexOf("missing") >= 0 ? Theme.lineDim : "transparent"
                            border.color: index % 2 === 0 ? Theme.lineDim : "transparent"
                            border.width: Theme.lineWidth

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: Theme.densitySmallSpacing

                                TacticalLabel {
                                    text: String(index).padStart(2, "0")
                                    accent: true
                                }

                                TacticalLabel {
                                    text: modelData.indexOf("fallback") >= 0 || modelData.indexOf("missing") >= 0 ? "WARN" : "OK"
                                    accent: modelData.indexOf("fallback") >= 0 || modelData.indexOf("missing") >= 0
                                    dim: modelData.indexOf("fallback") < 0 && modelData.indexOf("missing") < 0
                                }

                                TacticalLabel {
                                    Layout.fillWidth: true
                                    text: modelData
                                    elide: Text.ElideRight
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
                    title: "EVENT BUS"
                    lines: ["EVENTS: " + root.logLines.length, "WARNINGS: " + root.warningCount, "SOURCE: SERVICES + SYSTEMSTATS", "WARN RULE: fallback/missing", "MODE: LOCAL STATUS MIRROR", "ACTIONS: READ ONLY"]
                }

                MetricBlock {
                    title: "EVENT HEALTH"
                    rows: [["TOTAL", root.logLines.length.toString(), Math.min(1, root.logLines.length / 16), true], ["WARN", root.warningCount.toString(), Math.min(1, root.warningCount / 6), root.warningCount > 0], ["OK", Math.max(0, root.logLines.length - root.warningCount).toString(), Math.min(1, (root.logLines.length - root.warningCount) / 16), root.warningCount === 0]]
                }

                TextBlock {
                    title: "SERVICE SNAPSHOT"
                    lines: [SettingsService.statusLine, ExpansionService.statusLine, NotificationService.statusLine, ClipboardService.statusLine, LauncherService.statusLine]
                }

                TextBlock {
                    title: "TACTICAL NOTES"
                    lines: ["CLICK BACKDROP TO DISMISS", "LOG TAIL HELPER: DEFERRED", "PERSISTENT JOURNAL: DEFERRED", "NO RAW STDERR IN UI"]
                }
            }
        }
    }
}
