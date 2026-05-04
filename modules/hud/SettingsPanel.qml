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
        height: Math.min(420, parent.height - Theme.margin * 2)
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

            TextBlock {
                title: "STATUS"
                lines: ["settings persistence: pending", "theme backend: qml live state", "zig backend: planned"]
            }

            Item {
                Layout.fillHeight: true
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: "NEXT: persist settings + add zig-backed config helper"
                dim: true
            }

        }

    }

}
