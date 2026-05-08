import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "SERVICE EVENT BUS // DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT LOG NODE // LOCAL SERVICE EVENTS"

    readonly property var serviceMirror: [CompositorService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, AudioService.micStatusLine, BatteryService.statusLine, MediaService.statusLine, WeatherService.statusLine, KeyboardService.statusLine, PowerProfileService.statusLine, PowerProfileService.idleStatusLine].concat(SystemStats.logLines)
    readonly property bool hasServiceEvents: ServiceLogService.events.length > 0
    function isWarningLine(line: string): bool {
        const normalized = String(line).toLowerCase();
        return normalized.indexOf("fallback") >= 0 || normalized.indexOf("missing") >= 0 || normalized.indexOf("error") >= 0;
    }

    function visibleRowCount(): int {
        return root.hasServiceEvents ? ServiceLogService.events.length : root.serviceMirror.length;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        PanelStatusStrip {
            leftText: root.hasServiceEvents ? "EVENT BUS // LIVE" : "EVENT BUS // SNAPSHOT"
            centerText: (root.hasServiceEvents ? "RECENT EVENTS // " : "STATUS MIRROR // ") + root.visibleRowCount()
            rightText: "ESC // CLOSE"
            warning: root.hasServiceEvents ? ServiceLogService.events.some(entry => entry.level !== "info" || root.isWarningLine(entry.message)) : root.serviceMirror.some(line => root.isWarningLine(line))
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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.densitySmallSpacing

                        TacticalLabel {
                            Layout.fillWidth: true
                            text: root.hasServiceEvents ? "LOCAL SERVICE EVENT BUS // NEWEST FIRST" : "NO EVENT BUS ENTRIES // SHOWING SERVICE STATUS SNAPSHOT"
                            accent: root.hasServiceEvents
                            dim: !root.hasServiceEvents
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.preferredWidth: 126
                            Layout.preferredHeight: Theme.densityControlHeight
                            color: clearLogArea.containsMouse && root.hasServiceEvents ? Theme.panelSoft : "transparent"
                            border.color: root.hasServiceEvents ? Theme.line : Theme.lineDim
                            border.width: Theme.lineWidth
                            opacity: root.hasServiceEvents ? 1 : 0.45

                            MouseArea {
                                id: clearLogArea

                                anchors.fill: parent
                                cursorShape: root.hasServiceEvents ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: root.hasServiceEvents
                                hoverEnabled: true
                                onClicked: ServiceLogService.clear()
                            }

                            TacticalLabel {
                                anchors.centerIn: parent
                                text: "CLEAR EVENTS"
                                accent: clearLogArea.containsMouse && root.hasServiceEvents
                                dim: !root.hasServiceEvents
                            }
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentHeight: streamColumn.implicitHeight

                        ColumnLayout {
                            id: streamColumn

                            width: parent.width
                            spacing: Theme.densitySmallSpacing

                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: root.hasServiceEvents

                                Repeater {
                                    model: ServiceLogService.events

                                    Rectangle {
                                        required property var modelData
                                        required property int index

                                        readonly property bool warning: modelData.level !== "info" || root.isWarningLine(modelData.message)

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Theme.densityRowHeight
                                        color: warning ? Theme.lineDim : "transparent"
                                        border.color: warning || index % 2 === 0 ? Theme.lineDim : "transparent"
                                        border.width: Theme.lineWidth

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            spacing: Theme.densitySmallSpacing

                                            TacticalLabel {
                                                Layout.preferredWidth: 54
                                                text: modelData.time
                                                dim: true
                                                size: Theme.fontTiny
                                            }

                                            TacticalLabel {
                                                Layout.preferredWidth: 72
                                                text: modelData.source.toUpperCase()
                                                accent: warning
                                                elide: Text.ElideRight
                                                size: Theme.fontTiny
                                            }

                                            TacticalLabel {
                                                Layout.preferredWidth: 44
                                                text: modelData.level.toUpperCase()
                                                accent: warning
                                                dim: !warning
                                                size: Theme.fontTiny
                                            }

                                            TacticalLabel {
                                                Layout.fillWidth: true
                                                text: modelData.message
                                                accent: warning
                                                dim: !warning
                                                elide: Text.ElideRight
                                                size: Theme.fontTiny
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: !root.hasServiceEvents

                                Repeater {
                                    model: root.serviceMirror

                                    Rectangle {
                                        required property string modelData
                                        required property int index

                                        readonly property bool warning: root.isWarningLine(modelData)

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Theme.densityRowHeight
                                        color: warning ? Theme.lineDim : "transparent"
                                        border.color: warning || index % 2 === 0 ? Theme.lineDim : "transparent"
                                        border.width: Theme.lineWidth

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            spacing: Theme.densitySmallSpacing

                                            TacticalLabel {
                                                Layout.preferredWidth: 54
                                                text: String(index).padStart(2, "0")
                                                dim: true
                                                size: Theme.fontTiny
                                            }

                                            TacticalLabel {
                                                Layout.preferredWidth: 72
                                                text: "snapshot"
                                                accent: warning
                                                elide: Text.ElideRight
                                                size: Theme.fontTiny
                                            }

                                            TacticalLabel {
                                                Layout.preferredWidth: 44
                                                text: warning ? "WARN" : "OK"
                                                accent: warning
                                                dim: !warning
                                                size: Theme.fontTiny
                                            }

                                            TacticalLabel {
                                                Layout.fillWidth: true
                                                text: modelData
                                                accent: warning
                                                dim: !warning
                                                elide: Text.ElideRight
                                                size: Theme.fontTiny
                                            }
                                        }
                                    }
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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.densitySmallSpacing * 0.5

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "EVENT BUS"
                        accent: true
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "EVENTS: " + ServiceLogService.events.length
                        elide: Text.ElideRight
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "SOURCE: LOCAL SERVICE BUS"
                        elide: Text.ElideRight
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "PRIMARY: ServiceLogService.events"
                        accent: root.hasServiceEvents
                        dim: !root.hasServiceEvents
                        elide: Text.ElideRight
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "FALLBACK: SERVICE STATUS SNAPSHOT"
                        elide: Text.ElideRight
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "ACTIONS: CLEAR LOCAL EVENTS"
                        elide: Text.ElideRight
                    }
                }

                TextBlock {
                    title: "SERVICE SNAPSHOT"
                    lines: [SettingsService.statusLine, ExpansionService.statusLine, NotificationService.statusLine, ClipboardService.statusLine, LauncherService.statusLine]
                }

                TextBlock {
                    title: "TACTICAL NOTES"
                    lines: ["CLICK BACKDROP TO DISMISS", "LOCAL SERVICE EVENT BUS ONLY", "EXTERNAL LOG TAIL: OUT OF SCOPE", "PERSISTENT JOURNAL: DEFERRED", "NO RAW STDERR IN UI"]
                }
            }
        }
    }
}
