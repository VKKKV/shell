import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: Theme.densitySpacing

    TacticalLabel {
        Layout.fillWidth: true
        text: "VISUAL // ACCENT " + SettingsService.accentColor + " // DATA // PANELS"
        accent: true
    }

    SectionHeader {
        tag: "01"
        text: "VISUAL PALETTE"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 5
        rowSpacing: Theme.densitySmallSpacing
        columnSpacing: Theme.densitySmallSpacing

        Repeater {
            model: ["#F2C94C", "#FFB900", "#96BF48", "#55B7FF", "#FF4D2E"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.densityControlHeight
                color: SettingsService.accentColor === modelData ? Theme.lineDim : "transparent"
                border.color: SettingsService.accentColor === modelData ? Theme.line : Theme.border
                border.width: Theme.lineWidth

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SettingsService.accentColor = parent.modelData
                }

                TacticalLabel {
                    anchors.centerIn: parent
                    text: parent.modelData
                    accent: SettingsService.accentColor === parent.modelData
                    dim: SettingsService.accentColor !== parent.modelData
                    size: Theme.fontTiny
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 4
        rowSpacing: Theme.densitySmallSpacing
        columnSpacing: Theme.densitySmallSpacing

        Repeater {
            model: ["amber", "green", "blue", "red"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.densityControlHeight
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

    SectionHeader {
        tag: "02"
        text: "BACKDROP AND WALLPAPER"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: Theme.densitySmallSpacing
        columnSpacing: Theme.densitySmallSpacing

        Repeater {
            model: ["void", "grid", "radar"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.densityControlHeight
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
        spacing: Theme.densitySmallSpacing

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.densityControlHeight
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
            Layout.preferredHeight: Theme.densityControlHeight
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
            Layout.preferredHeight: Theme.densityControlHeight
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
            Layout.preferredHeight: Theme.densityControlHeight
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

    SectionHeader {
        tag: "03"
        text: "SYSTEM DATA AND INPUT"
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
        label: "NETWORK GEOLOCATION"
        checked: SettingsService.networkGeolocationEnabled
        onToggled: (checked) => SettingsService.networkGeolocationEnabled = checked
    }

    TextBlock {
        title: "EARTH LOCATION // PRIVACY"
        lines: [
            "mode: " + (SettingsService.networkGeolocationEnabled ? "network IP lookup" : "offline timezone inference"),
            "source: " + EarthLocationService.source,
            EarthLocationService.statusLine,
            "network mode contacts ipapi.co and exposes the public egress IP"
        ]
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "MICROPHONE // " + AudioService.micText
        accent: AudioService.micAvailable && !AudioService.micMuted
        dim: !AudioService.micAvailable || AudioService.micMuted
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.densitySmallSpacing

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.densityControlHeight
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
            Layout.preferredHeight: Theme.densityControlHeight
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
            Layout.preferredHeight: Theme.densityControlHeight
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

    SectionHeader {
        tag: "04"
        text: "PANEL VISIBILITY"
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

    SectionHeader {
        tag: "05"
        text: "TYPOGRAPHY AND DENSITY"
    }

    MetricRow {
        label: "INTENSITY"
        value: Math.round(SettingsService.intensity * 100) + "%"
        progress: SettingsService.intensity
        accent: true
    }

    AdjustmentRow {
        decrementText: "-"
        incrementText: "+"
        onDecrement: SettingsService.intensity = Math.max(0.5, SettingsService.intensity - 0.1)
        onIncrement: SettingsService.intensity = Math.min(1.5, SettingsService.intensity + 0.1)
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "DENSITY // " + SettingsService.density.toUpperCase()
        accent: SettingsService.density !== "normal"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: Theme.densitySmallSpacing
        columnSpacing: Theme.densitySmallSpacing

        Repeater {
            model: ["compact", "normal", "dense"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.densityControlHeight
                color: SettingsService.density === modelData ? Theme.lineDim : "transparent"
                border.color: SettingsService.density === modelData ? Theme.line : Theme.lineDim
                border.width: Theme.lineWidth

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SettingsService.density = parent.modelData
                }

                TacticalLabel {
                    anchors.centerIn: parent
                    text: parent.modelData.toUpperCase()
                    accent: SettingsService.density === parent.modelData
                    dim: SettingsService.density !== parent.modelData
                    size: Theme.fontTiny
                }
            }
        }
    }

    MetricRow {
        label: "FONT SCALE"
        value: Math.round(SettingsService.fontScale * 100) + "%"
        progress: (SettingsService.fontScale - 0.85) / 0.4
        accent: true
    }

    AdjustmentRow {
        decrementText: "FONT -"
        incrementText: "FONT +"
        onDecrement: SettingsService.fontScale = Math.max(0.85, SettingsService.fontScale - 0.05)
        onIncrement: SettingsService.fontScale = Math.min(1.25, SettingsService.fontScale + 0.05)
    }

    SectionHeader {
        tag: "06"
        text: "SURFACE AND SCANLINES"
    }

    MetricRow {
        label: "PANEL OPACITY"
        value: Math.round(SettingsService.panelOpacity * 100) + "%"
        progress: (SettingsService.panelOpacity - 0.55) / 0.4
        accent: true
    }

    AdjustmentRow {
        decrementText: "PANEL -"
        incrementText: "PANEL +"
        onDecrement: SettingsService.panelOpacity = Math.max(0.55, SettingsService.panelOpacity - 0.05)
        onIncrement: SettingsService.panelOpacity = Math.min(0.95, SettingsService.panelOpacity + 0.05)
    }

    MetricRow {
        label: "SCANLINE STRENGTH"
        value: Math.round(SettingsService.scanlineStrength * 100) + "%"
        progress: (SettingsService.scanlineStrength - 0.25) / 1.5
        accent: SettingsService.scanlinesEnabled
    }

    AdjustmentRow {
        decrementText: "SCAN -"
        incrementText: "SCAN +"
        onDecrement: SettingsService.scanlineStrength = Math.max(0.25, SettingsService.scanlineStrength - 0.25)
        onIncrement: SettingsService.scanlineStrength = Math.min(1.75, SettingsService.scanlineStrength + 0.25)
    }

    SectionHeader {
        tag: "07"
        text: "CONTRAST TUNING"
    }

    MetricRow {
        label: "BORDER OPACITY"
        value: Math.round(SettingsService.borderOpacity * 100) + "%"
        progress: (SettingsService.borderOpacity - 0.35) / 0.65
        accent: true
    }

    AdjustmentRow {
        decrementText: "BORDER -"
        incrementText: "BORDER +"
        onDecrement: SettingsService.borderOpacity = Math.max(0.35, SettingsService.borderOpacity - 0.05)
        onIncrement: SettingsService.borderOpacity = Math.min(1, SettingsService.borderOpacity + 0.05)
    }

    MetricRow {
        label: "DIM TEXT"
        value: Math.round(SettingsService.dimTextOpacity * 100) + "%"
        progress: (SettingsService.dimTextOpacity - 0.45) / 0.55
        accent: true
    }

    AdjustmentRow {
        decrementText: "DIM -"
        incrementText: "DIM +"
        onDecrement: SettingsService.dimTextOpacity = Math.max(0.45, SettingsService.dimTextOpacity - 0.05)
        onIncrement: SettingsService.dimTextOpacity = Math.min(1, SettingsService.dimTextOpacity + 0.05)
    }

    MetricRow {
        label: "LINE CONTRAST"
        value: Math.round(SettingsService.lineContrast * 100) + "%"
        progress: (SettingsService.lineContrast - 0.65) / 0.7
        accent: true
    }

    AdjustmentRow {
        decrementText: "LINE -"
        incrementText: "LINE +"
        onDecrement: SettingsService.lineContrast = Math.max(0.65, SettingsService.lineContrast - 0.05)
        onIncrement: SettingsService.lineContrast = Math.min(1.35, SettingsService.lineContrast + 0.05)
    }

    SectionHeader {
        tag: "08"
        text: "POLLING CADENCE"
    }

    MetricRow {
        label: "POLL RATE"
        value: (SettingsService.updateIntervalMs / 1000).toFixed(0) + "S"
        progress: (SettingsService.updateIntervalMs - 1000) / 29000
        accent: true
    }

    AdjustmentRow {
        decrementText: "-1S"
        incrementText: "+1S"
        onDecrement: SettingsService.updateIntervalMs = Math.max(1000, SettingsService.updateIntervalMs - 1000)
        onIncrement: SettingsService.updateIntervalMs = Math.min(30000, SettingsService.updateIntervalMs + 1000)
    }
}
