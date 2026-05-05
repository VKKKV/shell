import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 12

    TextBlock {
        title: "SYSTEM OVERVIEW"
        lines: ["workspace: " + HyprlandService.activeWorkspace, "active: " + HyprlandService.activeWindowClass + " // " + HyprlandService.activeWindowTitle, "date: " + CalendarService.dateText + " // " + CalendarService.dayText, "reserved: T" + HudMetrics.topReserved + " B" + HudMetrics.bottomReserved + " L" + HudMetrics.leftReserved + " R" + HudMetrics.rightReserved, "network: " + NetworkDetailService.primaryName + " // " + NetworkDetailService.vpnStatus, "wifi: " + NetworkDetailService.wifiStatus, "audio: " + AudioService.volumeText + " // mic " + AudioService.micText, "keyboard: " + KeyboardService.activeLayout + " // " + KeyboardService.activeKeyboard, "weather: " + WeatherService.displayText, "media: " + MediaService.displayText]
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "WIFI SCAN // " + NetworkDetailService.wifiStatus
        accent: NetworkDetailService.wifiNetworks.length > 0
        dim: NetworkDetailService.wifiNetworks.length === 0
    }

    Repeater {
        model: NetworkDetailService.wifiNetworks.slice(0, 3)

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: modelData.active ? Theme.lineDim : "transparent"
            border.color: modelData.active ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                TacticalLabel {
                    text: modelData.active ? "LINK" : modelData.signal + "%"
                    accent: modelData.active
                    dim: !modelData.active
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.ssid
                    elide: Text.ElideRight
                    accent: modelData.active
                }

                TacticalLabel {
                    text: modelData.security
                    dim: true
                    elide: Text.ElideRight
                }
            }
        }
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "WINDOWS // WORKSPACE " + HyprlandService.activeWorkspace
        accent: true
    }

    Repeater {
        model: HyprlandService.currentWorkspaceWindows

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: modelData.active ? Theme.lineDim : (windowArea.containsMouse ? Theme.panelSoft : "transparent")
            border.color: modelData.active ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: windowArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: HyprlandService.focusWindow(parent.modelData.title)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                TacticalLabel {
                    text: modelData.appClass.toUpperCase()
                    accent: modelData.active
                    dim: !modelData.active
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.title
                    accent: modelData.active
                    elide: Text.ElideRight
                }
            }
        }
    }

    TextBlock {
        title: "AGENDA // LOCAL"
        lines: CalendarService.agenda
    }

    MetricBlock {
        title: "LIVE METRICS"
        rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false], ["AUDIO", AudioService.volumeText, AudioService.available ? AudioService.volume : -1, AudioService.available], ["MIC", AudioService.micText, AudioService.micAvailable ? AudioService.micVolume : -1, AudioService.micAvailable && !AudioService.micMuted], ["POWER", BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available]]
    }

    Sparkline {
        Layout.fillWidth: true
        Layout.preferredHeight: 38
        values: AudioService.spectrum
        barColor: AudioService.available && !AudioService.muted ? Theme.line : Theme.lineDim
    }

    TextBlock {
        title: "SERVICE STATUS"
        lines: [SettingsService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, AudioService.micStatusLine, BatteryService.statusLine, MediaService.statusLine, LauncherService.statusLine, NotificationService.statusLine, ClipboardService.statusLine, WeatherService.statusLine, PowerProfileService.statusLine, PowerProfileService.idleStatusLine, KeyboardService.statusLine]
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: NotificationService.dndEnabled ? Theme.lineDim : "transparent"
            border.color: NotificationService.dndEnabled ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.toggleDnd()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: NotificationService.dndEnabled ? "DND ENABLED" : "DND DISABLED"
                accent: NotificationService.dndEnabled
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.clear()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "CLEAR ALERTS"
                dim: true
            }
        }
    }
}
