import "../../components"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    title: "TERMINAL 01 // BASH"
    highlighted: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 38
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: Theme.panelSoft
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                TacticalLabel {
                    text: "root@tactical-node-02"
                    accent: true
                }

                TacticalLabel {
                    text: ":~#"
                    dim: true
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: "neofetch --tactical"
                    accent: true
                }

                TacticalLabel {
                    text: "PID 0420"
                    dim: true
                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            TerminalSection {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "SYSTEM IDENTITY"
                lines: [["OS", "PRTS-Hyprland Linux x86_64"], ["HOST", "Tactical Node 02"], ["KERNEL", "6.8.9-zen1-1-zen"], ["PKGS", "1342 (pacman)"], ["WM", "Hyprland (QML)", true], ["CPU", "AMD Ryzen 9 7950X (24) @ 5.65 GHz"], ["GPU", "NVIDIA GeForce RTX 4080"], ["MEMORY", "19.71 GiB / 31.30 GiB", true]]
            }

            Rectangle {
                Layout.preferredWidth: Theme.lineWidth
                Layout.fillHeight: true
                color: Theme.lineDim
            }

            ColumnLayout {
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                spacing: 10

                TacticalLabel {
                    text: "PACKAGE OPERATION"
                    accent: true
                }

                MetricRow {
                    label: "resolve"
                    value: "100%"
                    progress: 1
                    accent: true
                }

                MetricRow {
                    label: "download"
                    value: "100%"
                    progress: 1
                    accent: true
                }

                MetricRow {
                    label: "build"
                    value: "72%"
                    progress: 0.72
                }

                MetricRow {
                    label: "install"
                    value: "51%"
                    progress: 0.51
                }

                Sparkline {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    values: [0.42, 0.66, 0.35, 0.79, 0.51, 0.9, 0.74, 0.58, 0.83, 0.46]
                }

                TextBlock {
                    title: "CHANNEL"
                    lines: ["SYSTEM CHANNEL: SECURE", "TACTICAL LAYER: ONLINE", "QML RENDERER: ACTIVE"]
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: Theme.panelSoft
            border.color: Theme.lineDim

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 12

                TacticalLabel {
                    text: "TTY1"
                    dim: true
                }

                TacticalLabel {
                    text: "ROOT"
                    dim: true
                }

                TacticalLabel {
                    text: "NODE_02"
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
