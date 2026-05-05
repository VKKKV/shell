import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "LOG STREAM // EVENT DRILLDOWN"
    highlighted: true

    readonly property var logLines: [HyprlandService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, AudioService.micStatusLine, BatteryService.statusLine, MediaService.statusLine, WeatherService.statusLine, KeyboardService.statusLine, PowerProfileService.statusLine, PowerProfileService.idleStatusLine].concat(SystemStats.logLines)

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
                text: "DEPLOYED FROM RIGHT LOG NODE // SERVICE STATUS EVENT BUS"
                accent: true
                elide: Text.ElideRight
            }

            PanelCloseButton {
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
                onCloseRequested: ExpansionService.close()
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

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Repeater {
                        model: root.logLines

                        Rectangle {
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: modelData.indexOf("fallback") >= 0 || modelData.indexOf("missing") >= 0 ? Theme.lineDim : "transparent"
                            border.color: index % 2 === 0 ? Theme.lineDim : "transparent"
                            border.width: Theme.lineWidth

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

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
                spacing: 10

                TextBlock {
                    title: "EVENT BUS"
                    lines: ["EVENTS: " + root.logLines.length, "SOURCE: SERVICES + SYSTEMSTATS", "WARN RULE: fallback/missing", "MODE: LOCAL STATUS MIRROR", "ACTIONS: READ ONLY"]
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
