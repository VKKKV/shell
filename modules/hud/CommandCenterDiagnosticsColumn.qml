import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

ColumnLayout {
    id: root

    spacing: Theme.densitySpacing

    readonly property var serviceRows: [
        ["COMP", CompositorService.statusLine],
        ["STATS", SystemStats.statusLine],
        ["NET", NetworkDetailService.statusLine],
        ["AUDIO", AudioService.statusLine],
        ["MIC", AudioService.micStatusLine],
        ["MEDIA", MediaService.statusLine],
        ["BATTERY", BatteryService.statusLine],
        ["WEATHER", WeatherService.statusLine],
        ["ENV", EnvironmentService.statusLine],
        ["CLIP", ClipboardService.statusLine],
        ["LAUNCH", LauncherService.statusLine],
        ["NOTIFY", NotificationService.statusLine],
        ["KEYBD", KeyboardService.statusLine],
        ["KEYS", KeybindService.statusLine],
        ["EMOJI", EmojiService.statusLine],
        ["POWER", PowerProfileService.statusLine],
        ["IDLE", PowerProfileService.idleStatusLine],
        ["SESSION", SessionService.statusLine],
        ["WALL", WallpaperService.statusLine]
    ]

    function warningText(line: string): bool {
        const lower = line.toLowerCase();
        return lower.indexOf("fallback") >= 0 || lower.indexOf("missing") >= 0 || lower.indexOf("offline") >= 0 || lower.indexOf("failed") >= 0 || lower.indexOf("unavailable") >= 0 || lower.indexOf("no ") >= 0;
    }

    TextBlock {
        title: "RUNTIME // DIAGNOSTICS"
        lines: [
            "quickshell: QApplication native tray mode",
            "settings: " + SettingsService.statusLine,
            "helper: " + SettingsService.helperPath,
            "live data: " + (SettingsService.liveDataEnabled ? "ENABLED" : "DISABLED"),
            "scanlines: " + (SettingsService.scanlinesEnabled ? "ENABLED" : "DISABLED") + " // " + Math.round(SettingsService.scanlineStrength * 100) + "%",
            "tray: " + SystemTray.items.values.length + " status-notifier clients",
            "poll: " + (SettingsService.updateIntervalMs / 1000).toFixed(0) + "S // density " + SettingsService.density.toUpperCase()
        ]
    }

    MetricBlock {
        title: "HUD RESERVATION"
        rows: [["TOP", HudMetrics.topReserved + "PX", HudMetrics.topReserved > 0 ? 1 : 0, true], ["LEFT", HudMetrics.leftReserved + "PX", HudMetrics.leftReserved > 0 ? 1 : 0, SettingsService.leftVisible], ["RIGHT", HudMetrics.rightReserved + "PX", HudMetrics.rightReserved > 0 ? 1 : 0, SettingsService.rightVisible], ["BOTTOM", HudMetrics.bottomReserved + "PX", HudMetrics.bottomReserved > 0 ? 1 : 0, true]]
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "SERVICE MATRIX // " + serviceRows.length + " CHANNELS"
        accent: true
    }

    Repeater {
        model: root.serviceRows

        Rectangle {
            required property var modelData

            readonly property bool warning: root.warningText(modelData[1])

            Layout.fillWidth: true
            Layout.preferredHeight: Theme.densityRowHeight
            color: warning ? Theme.lineDim : "transparent"
            border.color: warning ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: Theme.densitySmallSpacing

                TacticalLabel {
                    Layout.preferredWidth: 58
                    text: parent.parent.modelData[0]
                    accent: parent.parent.warning
                    dim: !parent.parent.warning
                    elide: Text.ElideRight
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: parent.parent.modelData[1]
                    accent: parent.parent.warning
                    dim: !parent.parent.warning
                    elide: Text.ElideRight
                }
            }
        }
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "RECENT SERVICE EVENTS // " + ServiceLogService.events.length
        accent: ServiceLogService.events.length > 0
        dim: ServiceLogService.events.length === 0
    }

    Repeater {
        model: ServiceLogService.events.slice(0, 6)

        Rectangle {
            required property var modelData

            readonly property bool warning: modelData.level !== "info"

            Layout.fillWidth: true
            Layout.preferredHeight: Theme.densityRowHeight
            color: warning ? Theme.lineDim : "transparent"
            border.color: warning ? Theme.line : Theme.border
            border.width: Theme.lineWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: Theme.densitySmallSpacing

                TacticalLabel {
                    text: parent.parent.modelData.time
                    dim: true
                    size: Theme.fontTiny
                }

                TacticalLabel {
                    text: parent.parent.modelData.source.toUpperCase()
                    accent: parent.parent.warning
                    size: Theme.fontTiny
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: parent.parent.modelData.message
                    accent: parent.parent.warning
                    dim: !parent.parent.warning
                    elide: Text.ElideRight
                    size: Theme.fontTiny
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.densityControlHeight
        color: clearLogArea.containsMouse ? Theme.panelSoft : "transparent"
        border.color: ServiceLogService.events.length > 0 ? Theme.line : Theme.lineDim
        border.width: Theme.lineWidth
        opacity: ServiceLogService.events.length > 0 ? 1 : 0.45

        MouseArea {
            id: clearLogArea

            anchors.fill: parent
            cursorShape: ServiceLogService.events.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: ServiceLogService.events.length > 0
            hoverEnabled: true
            onClicked: ServiceLogService.clear()
        }

        TacticalLabel {
            anchors.centerIn: parent
            text: "CLEAR SERVICE LOG"
            accent: clearLogArea.containsMouse
            dim: ServiceLogService.events.length === 0
        }
    }
}
