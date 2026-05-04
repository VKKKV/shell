import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    title: "SYSTEM MONITOR MATRIX"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 38
        spacing: 10

        TacticalLabel {
            Layout.fillWidth: true
            text: "CPU // 12C/24T // LIVE LOAD"
            accent: true
        }

        CoreGrid {
            cores: SystemStats.cpuRows
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

        MetricBlock {
            title: "NETWORK // eno1"
            rows: SystemStats.networkRows
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            values: SystemStats.networkHistory
        }

        MetricBlock {
            title: "FILESYSTEM"
            rows: SystemStats.filesystemRows
        }

        TextBlock {
            title: "NODES // STATUS"
            lines: ["NODE_01  ONLINE", "NODE_02  ACTIVE 10.0.0.12", "NODE_03  ONLINE", "NODE_04  IDLE", "NODE_05  ONLINE"]
        }

        LogStream {
            lines: [HyprlandService.statusLine, SystemStats.statusLine, AudioService.statusLine, BatteryService.statusLine, MediaService.statusLine].concat(SystemStats.logLines)
        }

    }

}
