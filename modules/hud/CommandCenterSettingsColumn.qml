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

    TacticalLabel {
        Layout.fillWidth: true
        text: "BACKGROUND // " + SettingsService.backgroundMode.toUpperCase()
        accent: SettingsService.backgroundMode !== "void"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: 6
        columnSpacing: 6

        Repeater {
            model: ["void", "grid", "radar"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 24
                color: SettingsService.backgroundMode === modelData ? Theme.lineDim : "transparent"
                border.color: SettingsService.backgroundMode === modelData ? Theme.line : Theme.lineDim
                border.width: Theme.lineWidth

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SettingsService.backgroundMode = parent.modelData
                }

                TacticalLabel {
                    anchors.centerIn: parent
                    text: parent.modelData.toUpperCase()
                    accent: SettingsService.backgroundMode === parent.modelData
                    dim: SettingsService.backgroundMode !== parent.modelData
                }
            }
        }
    }

    TextBlock {
        title: "WALLPAPER // BACKDROP"
        lines: [WallpaperService.statusLine, WallpaperService.applyStatusLine, "sample: " + WallpaperService.dominantColor + " -> " + WallpaperService.suggestedProfile]
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: refreshWallpaperArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: refreshWallpaperArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: WallpaperService.refresh()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "SCAN"
                accent: refreshWallpaperArea.containsMouse
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: applyWallpaperArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: WallpaperService.selectedPath.length > 0 ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth
            opacity: WallpaperService.selectedPath.length > 0 ? 1 : 0.45

            MouseArea {
                id: applyWallpaperArea

                anchors.fill: parent
                cursorShape: WallpaperService.selectedPath.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: WallpaperService.selectedPath.length > 0
                hoverEnabled: true
                onClicked: WallpaperService.applySelected()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "APPLY"
                accent: applyWallpaperArea.containsMouse
                dim: WallpaperService.selectedPath.length === 0
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: colorProfileArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: colorProfileArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: WallpaperService.applySuggestedProfile()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "COLOR"
                accent: colorProfileArea.containsMouse
            }
        }
    }

    Repeater {
        model: WallpaperService.wallpapers.slice(0, 4)

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: WallpaperService.selectedPath === modelData.path ? Theme.lineDim : (wallpaperArea.containsMouse ? Theme.panelSoft : "transparent")
            border.color: WallpaperService.selectedPath === modelData.path ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: wallpaperArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: WallpaperService.select(parent.modelData.path)
            }

            TacticalLabel {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: Text.AlignVCenter
                text: parent.modelData.name
                accent: WallpaperService.selectedPath === parent.modelData.path
                elide: Text.ElideRight
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

    TacticalLabel {
        Layout.fillWidth: true
        text: "MICROPHONE // " + AudioService.micText
        accent: AudioService.micAvailable && !AudioService.micMuted
        dim: !AudioService.micAvailable || AudioService.micMuted
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: "transparent"
            border.color: Theme.lineDim
            opacity: AudioService.micAvailable ? 1 : 0.45

            MouseArea {
                anchors.fill: parent
                cursorShape: AudioService.micAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: AudioService.micAvailable
                onClicked: AudioService.changeMicVolume(-0.05)
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "MIC -"
                accent: AudioService.micAvailable
                dim: !AudioService.micAvailable
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: AudioService.micMuted ? Theme.lineDim : "transparent"
            border.color: AudioService.micAvailable ? Theme.line : Theme.lineDim
            opacity: AudioService.micAvailable ? 1 : 0.45

            MouseArea {
                anchors.fill: parent
                cursorShape: AudioService.micAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: AudioService.micAvailable
                onClicked: AudioService.toggleMicMute()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: AudioService.micMuted ? "MIC MUTED" : "MIC LIVE"
                accent: AudioService.micAvailable && !AudioService.micMuted
                dim: !AudioService.micAvailable || AudioService.micMuted
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: "transparent"
            border.color: Theme.lineDim
            opacity: AudioService.micAvailable ? 1 : 0.45

            MouseArea {
                anchors.fill: parent
                cursorShape: AudioService.micAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: AudioService.micAvailable
                onClicked: AudioService.changeMicVolume(0.05)
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "MIC +"
                accent: AudioService.micAvailable
                dim: !AudioService.micAvailable
            }
        }
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
