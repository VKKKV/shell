import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "NETWORK MATRIX // LINK DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT NETWORK NODE // NMCLI + /PROC/NET/DEV TELEMETRY"

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
                    title: "THROUGHPUT BUS"
                    rows: SystemStats.networkRows
                }

                Sparkline {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.densityGraphHeight + Theme.densityControlHeight
                    values: SystemStats.networkHistory
                }

                MetricBlock {
                    title: "LINK DETAIL"
                    rows: NetworkDetailService.rows
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: "WIFI SCAN // " + NetworkDetailService.wifiStatus
                    accent: NetworkDetailService.wifiNetworks.length > 0
                    dim: NetworkDetailService.wifiNetworks.length === 0
                }

                Repeater {
                    model: NetworkDetailService.wifiNetworks

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityRowHeight
                        color: modelData.active ? Theme.lineDim : "#44000000"
                        border.color: modelData.active ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: Theme.densitySmallSpacing

                            TacticalLabel {
                                text: modelData.active ? "LINK" : modelData.signal + "%"
                                accent: modelData.active
                                dim: !modelData.active
                            }

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: modelData.ssid
                                elide: Text.ElideRight
                                accent: modelData.active
                            }

                            TacticalLabel {
                                text: modelData.security
                                dim: true
                                elide: Text.ElideRight
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
                    title: "LINK STATUS"
                    lines: [NetworkDetailService.statusLine, "PRIMARY: " + NetworkDetailService.primaryName, "TYPE: " + NetworkDetailService.primaryType, "VPN: " + NetworkDetailService.vpnStatus, "BT: " + NetworkDetailService.bluetoothStatus]
                }

                TextBlock {
                    title: "ACTIVE CONNECTIONS"
                    lines: NetworkDetailService.activeConnections.map(connection => connection.name + " // " + connection.type.toUpperCase() + " // " + (connection.device || "NODE"))
                }

                TextBlock {
                    title: "TACTICAL NOTES"
                    lines: ["CLICK BACKDROP TO DISMISS", "CONNECTION FLOWS: DEFERRED", "PACKET GRAPH: LIVE HISTORY", "WIFI AUTH: OUT OF SCOPE"]
                }
            }
        }
    }
}
