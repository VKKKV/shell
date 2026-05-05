import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    title: "SYSTEM MONITOR MATRIX"
    implicitWidth: Math.max(Theme.rightPanelMinWidth, content.implicitWidth + Theme.panelPadding * 2)
    implicitHeight: Math.min(Theme.sidePanelMaxHeight, content.implicitHeight + Theme.panelPadding + 38)

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 38
        spacing: 10

        TacticalLabel {
            Layout.fillWidth: true
            text: "CPU // 12C/24T // LIVE LOAD"
            accent: true
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: cpuGrid.implicitHeight

            CoreGrid {
                id: cpuGrid

                anchors.left: parent.left
                anchors.right: parent.right
                cores: SystemStats.cpuRows
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ExpansionService.show("cpu", "right-cpu")
            }
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            values: SystemStats.cpuHistory
        }

        MetricBlock {
            title: "MEMORY BUS"
            rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false]]
        }

        MetricBlock {
            title: "POWER SOURCE"
            rows: [[BatteryService.label, BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available]]
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: networkStack.implicitHeight

            ColumnLayout {
                id: networkStack

                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                MetricBlock {
                    title: "NETWORK // eno1"
                    rows: SystemStats.networkRows
                }

                MetricBlock {
                    title: "NETWORK DETAIL"
                    rows: NetworkDetailService.rows
                }

                Sparkline {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    values: SystemStats.networkHistory
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ExpansionService.show("network", "right-network")
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: filesystemBlock.implicitHeight

            MetricBlock {
                id: filesystemBlock

                title: "FILESYSTEM"
                rows: SystemStats.filesystemRows
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ExpansionService.show("filesystem", "right-filesystem")
            }
        }

        TextBlock {
            title: "NODES // STATUS"
            lines: ["NODE_01  ONLINE", "NODE_02  ACTIVE 10.0.0.12", "NODE_03  ONLINE", "NODE_04  IDLE", "NODE_05  ONLINE"]
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: logStream.implicitHeight

            LogStream {
                id: logStream

                lines: [HyprlandService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, BatteryService.statusLine, MediaService.statusLine].concat(SystemStats.logLines)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ExpansionService.show("logs", "right-logs")
            }
        }

    }

}
