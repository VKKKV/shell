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
            cores: [["C00", "12%", 0.12, false], ["C06", "41%", 0.41, false], ["C01", "08%", 0.08, false], ["C07", "37%", 0.37, false], ["C02", "22%", 0.22, false], ["C08", "19%", 0.19, false], ["C03", "16%", 0.16, false], ["C09", "55%", 0.55, true], ["C04", "31%", 0.31, false], ["C10", "28%", 0.28, false], ["C05", "44%", 0.44, false], ["C11", "33%", 0.33, false]]
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            values: [0.32, 0.36, 0.44, 0.28, 0.58, 0.67, 0.42, 0.5, 0.74, 0.62, 0.46, 0.7, 0.55, 0.38, 0.48, 0.8, 0.52, 0.34]
        }

        MetricBlock {
            title: "MEMORY BUS"
            rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false]]
        }

        MetricBlock {
            title: "NETWORK // eno1"
            rows: [["DOWN", "924.4 KiB/s", 0.76, true], ["UP", "88.1 KiB/s", 0.24, false], ["LINK", "SECURE", -1, true]]
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            values: [0.18, 0.42, 0.3, 0.74, 0.52, 0.64, 0.21, 0.82, 0.36, 0.57, 0.7, 0.25]
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
            lines: ["audit: root access granted", "net: eno1 link secure", "pkg: qml renderer updated", "matrix: tactical sync 100%"]
        }

    }

}
