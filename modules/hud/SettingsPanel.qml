import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    visible: SettingsService.panelOpen
    opacity: visible ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
    }

    TacticalFrame {
        width: Math.min(920, parent.width - Theme.margin * 2)
        height: Math.min(620, parent.height - Theme.margin * 2)
        anchors.centerIn: parent
        title: "COMMAND CENTER // TACTICAL CONTROL"
        highlighted: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.panelPadding
            anchors.topMargin: 40
            spacing: 14

            TacticalLabel {
                Layout.fillWidth: true
                text: "CTRL+ALT+S TO TOGGLE PANEL"
                dim: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    TextBlock {
                        title: "SYSTEM OVERVIEW"
                        lines: ["workspace: " + HyprlandService.activeWorkspace, "reserved: T" + HudMetrics.topReserved + " B" + HudMetrics.bottomReserved + " L" + HudMetrics.leftReserved + " R" + HudMetrics.rightReserved, "media: " + MediaService.displayText]
                    }

                    MetricBlock {
                        title: "LIVE METRICS"
                        rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false], ["AUDIO", AudioService.volumeText, AudioService.available ? AudioService.volume : -1, AudioService.available], ["POWER", BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available]]
                    }

                    TextBlock {
                        title: "SERVICE STATUS"
                        lines: [SettingsService.statusLine, SystemStats.statusLine, AudioService.statusLine, BatteryService.statusLine, MediaService.statusLine]
                    }

                }

                Rectangle {
                    Layout.preferredWidth: Theme.lineWidth
                    Layout.fillHeight: true
                    color: Theme.lineDim
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    TacticalLabel {
                        Layout.fillWidth: true
                        text: "VISUAL // DATA // PANELS"
                        accent: true
                    }

                    ToggleRow {
                        label: "SCANLINE OVERLAY"
                        checked: SettingsService.scanlinesEnabled
                        onToggled: (checked) => {
                            return SettingsService.scanlinesEnabled = checked;
                        }
                    }

                    ToggleRow {
                        label: "LIVE DATA FEED"
                        checked: SettingsService.liveDataEnabled
                        onToggled: (checked) => {
                            return SettingsService.liveDataEnabled = checked;
                        }
                    }

                    ToggleRow {
                        label: "LEFT PANEL"
                        checked: SettingsService.leftVisible
                        onToggled: (checked) => {
                            return SettingsService.leftVisible = checked;
                        }
                    }

                    ToggleRow {
                        label: "RIGHT PANEL"
                        checked: SettingsService.rightVisible
                        onToggled: (checked) => {
                            return SettingsService.rightVisible = checked;
                        }
                    }

                    MetricRow {
                        label: "INTENSITY"
                        value: Math.round(SettingsService.intensity * 100) + "%"
                        progress: SettingsService.intensity
                        accent: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            color: "transparent"
                            border.color: Theme.lineDim

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsService.intensity = Math.max(0.5, SettingsService.intensity - 0.1)
                            }

                            TacticalLabel {
                                anchors.centerIn: parent
                                text: "-"
                                accent: true
                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            color: "transparent"
                            border.color: Theme.lineDim

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsService.intensity = Math.min(1.5, SettingsService.intensity + 0.1)
                            }

                            TacticalLabel {
                                anchors.centerIn: parent
                                text: "+"
                                accent: true
                            }

                        }

                    }

                    MetricRow {
                        label: "POLL RATE"
                        value: (SettingsService.updateIntervalMs / 1000).toFixed(0) + "S"
                        progress: (SettingsService.updateIntervalMs - 1000) / 29000
                        accent: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            color: "transparent"
                            border.color: Theme.lineDim

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsService.updateIntervalMs = Math.max(1000, SettingsService.updateIntervalMs - 1000)
                            }

                            TacticalLabel {
                                anchors.centerIn: parent
                                text: "-1S"
                                accent: true
                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            color: "transparent"
                            border.color: Theme.lineDim

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SettingsService.updateIntervalMs = Math.min(30000, SettingsService.updateIntervalMs + 1000)
                            }

                            TacticalLabel {
                                anchors.centerIn: parent
                                text: "+1S"
                                accent: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.preferredWidth: Theme.lineWidth
                    Layout.fillHeight: true
                    color: Theme.lineDim
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    TextBlock {
                        title: "SESSION // POWER"
                        lines: [SessionService.statusLine, "click once to arm, click same action again to execute"]
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: ["lock", "logout", "reboot", "shutdown"]

                            Rectangle {
                                required property string modelData

                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                color: SessionService.pendingAction === modelData ? Theme.lineDim : "transparent"
                                border.color: SessionService.pendingAction === modelData ? Theme.line : Theme.lineDim
                                border.width: Theme.lineWidth

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SessionService.confirm(parent.modelData)
                                }

                                TacticalLabel {
                                    anchors.centerIn: parent
                                    text: parent.modelData.toUpperCase()
                                    accent: SessionService.pendingAction === parent.modelData
                                    dim: SessionService.pendingAction !== parent.modelData
                                }

                            }

                        }

                    }

                    TextBlock {
                        title: "CONFIG"
                        lines: ["$XDG_CONFIG_HOME/void-shell/settings.json", "schema normalization: active", "helper: void-shell-settings"]
                    }

                }

            }

        }

    }

}
