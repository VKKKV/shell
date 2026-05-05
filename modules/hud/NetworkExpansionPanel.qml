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
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                MetricBlock {
                    title: "THROUGHPUT BUS"
                    rows: SystemStats.networkRows
                }

                Sparkline {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
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
                        Layout.preferredHeight: 30
                        color: modelData.active ? Theme.lineDim : "#44000000"
                        border.color: modelData.active ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

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
                spacing: 10

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
