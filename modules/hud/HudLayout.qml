import "../../components"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        opacity: 0.88
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.margin
        spacing: Theme.gap

        TopStatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.topBarHeight
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.gap

            TacticalFrame {
                Layout.preferredWidth: Theme.sidePanelWidth
                Layout.fillHeight: true
                title: "TACTICAL // THERMAL"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.panelPadding
                    anchors.topMargin: 38
                    spacing: 12

                    MetricBlock {
                        title: "TACTICAL LAYER"
                        rows: [["STATUS", "ONLINE", -1, true], ["SYNC RATE", "100%", 1, false], ["SIGNAL STR", "98%", 0.98, false], ["ENCRYPTION", "AES-256", -1, false]]
                    }

                    Sparkline {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        values: [0.2, 0.5, 0.32, 0.72, 0.45, 0.9, 0.62, 0.36, 0.78, 0.54, 0.26, 0.66]
                    }

                    MetricBlock {
                        title: "THERMAL MAP"
                        rows: [["CPU", "54C", 0.54, false], ["GPU", "48C", 0.48, false], ["VRM", "46C", 0.46, false], ["PCH", "42C", 0.42, false], ["SSD", "39C", 0.39, false]]
                    }

                    MetricBlock {
                        title: "POWER GRID"
                        rows: [["TOTAL", "425W", 0.85, true], ["GPU", "186W", 0.62, false], ["CPU", "92W", 0.38, false]]
                    }

                }

            }

            TacticalFrame {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "TERMINAL 01 // BASH"
                highlighted: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.panelPadding
                    anchors.topMargin: 38
                    spacing: 10

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "root@tactical-node-02:~# neofetch --tactical"
                        accent: true
                        size: Theme.fontNormal
                    }

                    TacticalLabel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: "OS:       PRTS-Hyprland Linux x86_64\nHOST:     Tactical Node 02\nKERNEL:   6.8.9-zen1-1-zen\nPKGS:     1342 (pacman)\nWM:       Hyprland (QML)\nCPU:      AMD Ryzen 9 7950X (24) @ 5.65 GHz\nGPU:      NVIDIA GeForce RTX 4080\nMEMORY:   19.71 GiB / 31.30 GiB\n\n:: resolving dependencies...\n:: downloading hyprland-qml-git...       [##########] 100%\n:: building quickshell tactical modules   [#######---] 72%\n:: installing package payload             [#####-----] 51%\n\nSYSTEM CHANNEL: SECURE\nTACTICAL LAYER: ONLINE"
                        size: Theme.fontNormal
                        lineHeight: 1.2
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        color: Theme.panelSoft
                        border.color: Theme.lineDim

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            TacticalLabel {
                                text: "TTY1"
                                dim: true
                            }

                            TacticalLabel {
                                text: "ROOT"
                                dim: true
                            }

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: "KERNEL 6.8.9-ZEN"
                                dim: true
                            }

                            TacticalLabel {
                                text: ">> LIVE"
                                accent: true
                            }

                        }

                    }

                }

            }

            TacticalFrame {
                Layout.preferredWidth: Theme.rightPanelWidth
                Layout.fillHeight: true
                title: "SYSTEM MONITOR MATRIX"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.panelPadding
                    anchors.topMargin: 38
                    spacing: 10

                    MetricBlock {
                        title: "CPU // 12C/24T"
                        rows: [["CORE 00", "12%", 0.12, false], ["CORE 01", "08%", 0.08, false], ["CORE 02", "22%", 0.22, false], ["CORE 03", "16%", 0.16, false], ["CORE 04", "31%", 0.31, false], ["CORE 05", "44%", 0.44, false]]
                    }

                    Sparkline {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        values: [0.32, 0.36, 0.44, 0.28, 0.58, 0.67, 0.42, 0.5, 0.74, 0.62, 0.46, 0.7, 0.55, 0.38, 0.48]
                    }

                    MetricBlock {
                        title: "RAM / SWAP"
                        rows: [["RAM", "19.7G 62.9%", 0.629, true], ["SWAP", "2.1G 26.2%", 0.262, false]]
                    }

                    MetricBlock {
                        title: "NETWORK // eno1"
                        rows: [["DOWN", "924.4 KiB/s", 0.76, true], ["UP", "88.1 KiB/s", 0.24, false]]
                    }

                    MetricBlock {
                        title: "FILESYSTEM"
                        rows: [["/", "72%", 0.72, false], ["/home", "64%", 0.64, false], ["/data", "41%", 0.41, false]]
                    }

                    TextBlock {
                        title: "NODES // STATUS"
                        lines: ["NODE_01  ONLINE", "NODE_02  ACTIVE 10.0.0.12", "NODE_03  ONLINE", "NODE_04  IDLE", "NODE_05  ONLINE"]
                    }

                    TextBlock {
                        title: "LOG STREAM // SYSTEM"
                        lines: ["audit: root access granted", "net: eno1 link secure", "pkg: qml renderer updated"]
                    }

                }

            }

        }

        BottomStatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.bottomBarHeight
        }

    }

    component MetricBlock: ColumnLayout {
        id: block

        property string title: ""
        property var rows: []

        Layout.fillWidth: true
        spacing: 6

        TacticalLabel {
            Layout.fillWidth: true
            text: block.title
            accent: true
        }

        Repeater {
            model: block.rows

            MetricRow {
                required property var modelData

                label: modelData[0]
                value: modelData[1]
                progress: modelData[2]
                accent: modelData[3]
            }

        }

    }

    component TextBlock: ColumnLayout {
        id: block

        property string title: ""
        property var lines: []

        Layout.fillWidth: true
        spacing: 4

        TacticalLabel {
            Layout.fillWidth: true
            text: block.title
            accent: true
        }

        Repeater {
            model: block.lines

            TacticalLabel {
                required property string modelData

                Layout.fillWidth: true
                text: modelData
            }

        }

    }

}
