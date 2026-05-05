import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 12

    TextBlock {
        title: "SYSTEM OVERVIEW"
        lines: ["workspace: " + HyprlandService.activeWorkspace, "reserved: T" + HudMetrics.topReserved + " B" + HudMetrics.bottomReserved + " L" + HudMetrics.leftReserved + " R" + HudMetrics.rightReserved, "network: " + NetworkDetailService.primaryName + " // " + NetworkDetailService.vpnStatus, "media: " + MediaService.displayText]
    }

    MetricBlock {
        title: "LIVE METRICS"
        rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false], ["AUDIO", AudioService.volumeText, AudioService.available ? AudioService.volume : -1, AudioService.available], ["POWER", BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available]]
    }

    TextBlock {
        title: "SERVICE STATUS"
        lines: [SettingsService.statusLine, SystemStats.statusLine, NetworkDetailService.statusLine, AudioService.statusLine, BatteryService.statusLine, MediaService.statusLine, LauncherService.statusLine, NotificationService.statusLine]
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
