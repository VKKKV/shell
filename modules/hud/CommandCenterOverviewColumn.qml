import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 12

    TextBlock {
        title: "SYSTEM OVERVIEW"
        lines: ["compositor: " + CompositorService.compositorName + " // " + (CompositorService.available ? "online" : "fallback"), CompositorService.workspaceStatusLine, "active: " + CompositorService.activeWindowClass + " // " + CompositorService.activeWindowTitle, "date: " + CalendarService.dateText + " // " + CalendarService.dayText, "reserved: T" + HudMetrics.topReserved + " B" + HudMetrics.bottomReserved + " L" + HudMetrics.leftReserved + " R" + HudMetrics.rightReserved, "network: " + NetworkDetailService.primaryName + " // " + NetworkDetailService.vpnStatus, "wifi: " + NetworkDetailService.wifiStatus, "audio: " + AudioService.volumeText + " // mic " + AudioService.micText, "keyboard: " + KeyboardService.activeLayout + " // " + KeyboardService.activeKeyboard, "weather: " + WeatherService.displayText, "environment: " + EnvironmentService.nightLightText, "media: " + MediaService.displayText]
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "WIFI SCAN // " + NetworkDetailService.wifiStatus
        accent: NetworkDetailService.wifiNetworks.length > 0
        dim: NetworkDetailService.wifiNetworks.length === 0
    }

    TextBlock {
        title: "NETWORK ACTIONS"
        lines: [NetworkDetailService.actionStatusLine, "click AP to connect saved/open profile", "active links can reconnect or drop"]
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: wifiRescanArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: wifiRescanArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: NetworkDetailService.rescanWifi()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "WIFI RESCAN"
                accent: wifiRescanArea.containsMouse
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: NetworkDetailService.bluetoothStatus === "POWERED" ? Theme.lineDim : "transparent"
            border.color: NetworkDetailService.bluetoothStatus !== "OFFLINE" ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth
            opacity: NetworkDetailService.bluetoothStatus !== "OFFLINE" ? 1 : 0.45

            MouseArea {
                anchors.fill: parent
                cursorShape: NetworkDetailService.bluetoothStatus !== "OFFLINE" ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: NetworkDetailService.bluetoothStatus !== "OFFLINE"
                onClicked: NetworkDetailService.toggleBluetoothPower()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "BT // " + NetworkDetailService.bluetoothStatus
                accent: NetworkDetailService.bluetoothStatus === "POWERED"
                dim: NetworkDetailService.bluetoothStatus !== "POWERED"
            }
        }
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

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton)
                        NetworkDetailService.connectWifi(parent.modelData.ssid);
                }
            }
        }
    }

    Repeater {
        model: NetworkDetailService.activeConnections.slice(0, 3)

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: linkArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: linkArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        NetworkDetailService.deactivateConnection(parent.modelData.name);
                    else
                        NetworkDetailService.refreshConnection(parent.modelData.name);
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                TacticalLabel {
                    text: modelData.type.toUpperCase()
                    accent: true
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.name + " // " + modelData.device
                    elide: Text.ElideRight
                    accent: linkArea.containsMouse
                }

                TacticalLabel {
                    text: "L:UP R:DOWN"
                    dim: true
                }
            }
        }
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "WINDOWS // WORKSPACE " + CompositorService.activeWorkspace
        accent: true
    }

    Repeater {
        model: CompositorService.currentWorkspaceWindows

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
                onClicked: CompositorService.focusWindow(parent.modelData.title)
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
        title: "LYRICS // LOCAL"
        lines: [MediaService.lyricStatusLine].concat(MediaService.lyricLines)
    }

    TextBlock {
        title: "SERVICE STATUS"
        lines: [SettingsService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, AudioService.micStatusLine, BatteryService.statusLine, MediaService.statusLine, LauncherService.statusLine, NotificationService.statusLine, ClipboardService.statusLine, WeatherService.statusLine, EnvironmentService.statusLine, PowerProfileService.statusLine, PowerProfileService.idleStatusLine, KeyboardService.statusLine, KeybindService.statusLine, EmojiService.statusLine, ServiceLogService.statusLine]
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "SERVICE LOG // RECENT EVENTS"
        accent: ServiceLogService.events.length > 0
        dim: ServiceLogService.events.length === 0
    }

    Repeater {
        model: ServiceLogService.events.slice(0, 5)

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: modelData.level === "error" || modelData.level === "warn" ? Theme.lineDim : "transparent"
            border.color: modelData.level === "error" || modelData.level === "warn" ? Theme.line : Theme.border
            border.width: Theme.lineWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                TacticalLabel {
                    text: modelData.time
                    dim: true
                    size: Theme.fontTiny
                }

                TacticalLabel {
                    text: modelData.source.toUpperCase()
                    accent: modelData.level !== "info"
                    size: Theme.fontTiny
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.message
                    elide: Text.ElideRight
                    dim: modelData.level === "info"
                    accent: modelData.level !== "info"
                    size: Theme.fontTiny
                }
            }
        }
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
