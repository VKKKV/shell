import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 10

    TacticalLabel {
        Layout.fillWidth: true
        text: "VISUAL // DATA // PANELS"
        accent: true
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 4
        rowSpacing: 6
        columnSpacing: 6

        Repeater {
            model: ["amber", "green", "blue", "red"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 24
                color: SettingsService.themeProfile === modelData ? Theme.lineDim : "transparent"
                border.color: SettingsService.themeProfile === modelData ? Theme.line : Theme.lineDim
                border.width: Theme.lineWidth

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SettingsService.themeProfile = parent.modelData
                }

                TacticalLabel {
                    anchors.centerIn: parent
                    text: parent.modelData.toUpperCase()
                    accent: SettingsService.themeProfile === parent.modelData
                    dim: SettingsService.themeProfile !== parent.modelData
                }
            }
        }
    }

    ToggleRow {
        label: "SCANLINE OVERLAY"
        checked: SettingsService.scanlinesEnabled
        onToggled: (checked) => SettingsService.scanlinesEnabled = checked
    }

    ToggleRow {
        label: "LIVE DATA FEED"
        checked: SettingsService.liveDataEnabled
        onToggled: (checked) => SettingsService.liveDataEnabled = checked
    }

    ToggleRow {
        label: "LEFT PANEL"
        checked: SettingsService.leftVisible
        onToggled: (checked) => SettingsService.leftVisible = checked
    }

    ToggleRow {
        label: "RIGHT PANEL"
        checked: SettingsService.rightVisible
        onToggled: (checked) => SettingsService.rightVisible = checked
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
