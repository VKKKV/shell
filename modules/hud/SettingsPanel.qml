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
        width: Math.min(520, parent.width - Theme.margin * 2)
        height: Math.min(620, parent.height - Theme.margin * 2)
        anchors.centerIn: parent
        title: "SETTINGS // TACTICAL CONTROL"
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
                label: "CENTER PANEL"
                checked: SettingsService.centerVisible
                onToggled: (checked) => {
                    return SettingsService.centerVisible = checked;
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

            TextBlock {
                title: "STATUS"
                lines: [SettingsService.statusLine, "settings persistence: zig helper", "schema normalization: active"]
            }

            TextBlock {
                title: "SESSION // POWER"
                lines: [SessionService.statusLine, "click once to arm, click same action again to execute"]
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: ["lock", "logout", "reboot", "shutdown"]

                    Rectangle {
                        required property string modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
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

            Item {
                Layout.fillHeight: true
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "CONFIG: $XDG_CONFIG_HOME/void-shell/settings.json"
                dim: true
            }

        }

    }

}
